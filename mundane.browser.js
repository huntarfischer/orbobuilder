// mundane.browser.js — auto-generated browser-global build of mundane.js (no ES modules; assigns window.__ORBO_MUNDANE).
// Source of truth is mundane.js — regenerate this file if mundane.js changes, don't hand-edit.
// Load order: after loom.browser.js and ring.browser.js.
(function boot(){
// Bundle-safety: inlined blob scripts don't preserve <script> order, so wait for deps
// (see CLAUDE.md — browser-build-only guard, no analog in the ES-module source).
if(!window.__ORBO_FRAMING || !window.__ORBO_LOOM || !window.__ORBO_RING){return void setTimeout(boot,0);}
const { scanTargets, decorate, buildFloor, retroPeriods } = window.__ORBO_LOOM;
const { floorTargets, norm360, wrap180, signIndex, SIGNS, RULERS, BODIES } = window.__ORBO_FRAMING;
const { MARKS } = window.__ORBO_RING;
// mundane.js — Phase 5 · S3 · the embryo's source of truth.
//
// The sky's own event table, read with no native in it: native-independent, place-free,
// byte-identical for every reader. Orbo ships this; the native's data fertilizes it and the two
// weaves come out. This file is the FLOOR only. It knows nothing about a natal chart and must never
// learn: the moment it does, the embryo stops being one artifact for everybody.
//
// THE REASON TO SHIP RATHER THAN COMPUTE IS TRUST, NOT SIZE. Positions are already offline and
// already free (ephem.js is 18 KB of analytic elements plus the lunar series), so an ephemeris does
// not need shipping. What needs shipping is the part that can be VERIFIED ONCE and then be right
// forever, which above all means eclipses: a syzygy scan is not an eclipse. A new moon is an eclipse
// only if the Moon is near a node, and which KIND it is depends on two distances. Getting that
// wrong is both likely and embarrassing, so it is computed here, diffed against the published canon
// in tests/mundane.test.html, and never scanned at runtime.
//
// Two injection rules, both load-bearing:
//   · No scanning door of its own. The floor is loom.js's first target set; this file adds the
//     eclipse block and the codec, and hands loom a probe like everybody else.
//   · The 3D lunar and solar state arrives as INJECTED deps (`moonState`, `sunState`), never an
//     ephem import, so the reader path carries no ephemeris at all: reading the embryo is decoding.

const EMBRYO_SPAN = { y0: 1700, y1: 2100 };
const D2R = Math.PI / 180, R2D = 180 / Math.PI;
const R_EARTH = 6378.1366, R_MOON = 1737.4, R_SUN = 696000;
// Earth's shadow is enlarged by about 2% for the atmosphere (the standard factor, and the reason
// Meeus's umbral and penumbral constants come out at 0.7403 and 1.2848 degrees).
const ATMO = 1.02;

// ---------- geometry ----------
// Angular separation of two ecliptic directions. The Sun's own latitude is not zero to the precision
// that matters here, so both are carried.
function angSep(l1, b1, l2, b2) {
  const p1 = b1 * D2R, p2 = b2 * D2R, dl = wrap180(l1 - l2) * D2R;
  const c = Math.sin(p1) * Math.sin(p2) + Math.cos(p1) * Math.cos(p2) * Math.cos(dl);
  return Math.acos(Math.max(-1, Math.min(1, c))) * R2D;
}
const semi = (radius, dist) => Math.asin(Math.min(1, radius / dist)) * R2D;

// Least separation near a syzygy: the instant of greatest eclipse. Ternary search, because the
// separation is unimodal across the few hours that matter and a bisection has no sign to work with.
function leastSep(jd, f, half = 0.35) {
  let lo = jd - half, hi = jd + half;
  for (let i = 0; i < 60; i++) {
    const a = lo + (hi - lo) / 3, b = hi - (hi - lo) / 3;
    if (f(a) < f(b)) hi = b; else lo = a;
  }
  const t = (lo + hi) / 2;
  return { jd: t, sep: f(t) };
}

// ---------- the eclipse block ----------
// `kind` is 'solar' at a new moon, 'lunar' at a full moon. Returns null when the syzygy is just a
// syzygy, which is most of them: about 4 in 5.
function eclipseAt(jd, kind, dep) {
  const { moonState, sunState } = dep;
  const sepAt = kind === 'solar'
    ? (t) => { const m = moonState(t), s = sunState(t); return angSep(m.lon, m.lat, s.lon, 0); }
    // A lunar eclipse is the Moon meeting the ANTISOLAR point, so the shadow is where the Sun is not.
    : (t) => { const m = moonState(t), s = sunState(t); return angSep(m.lon, m.lat, s.lon + 180, 0); };
  const g = leastSep(jd, sepAt);
  const m = moonState(g.jd), s = sunState(g.jd);
  const piM = semi(R_EARTH, m.r), sM = semi(R_MOON, m.r), sS = semi(R_SUN, s.r), piS = semi(R_EARTH, s.r);
  const node = wrap180(m.lon - norm360(kind === 'solar' ? s.lon : s.lon + 180));

  if (kind === 'solar') {
    // gamma: the least distance of the shadow axis from Earth's centre, in Earth radii. The classic
    // limit |gamma| < 1.5433 + u is this same inequality with the mean radii substituted.
    const gamma = g.sep / piM;
    const limit = 1 + (sM + sS) / piM;
    if (gamma > limit) return null;
    const central = g.sep < piM;                        // the axis reaches the Earth at all
    // At the point where the axis strikes the surface the Moon is nearer than it is geocentrically,
    // so its disc is larger there, and THAT comparison decides total against annular. How much
    // nearer depends on gamma: the axis of a central eclipse passes through the Earth at a depth of
    // sqrt(1 - gamma^2) Earth radii, so a grazing eclipse gains almost nothing and a shadow cone
    // that would reach the centre can still fall short of an oblique surface. Leaving gamma out of
    // this is what turns every knife-edge annular into a false hybrid.
    const depth = R_EARTH * Math.sqrt(Math.max(0, 1 - gamma * gamma));
    const sTopo = semi(R_MOON, Math.max(1, m.r - depth));
    const ratio = sTopo / sS;
    // WE DO NOT CLAIM HYBRID. An annular-total eclipse is one that CHANGES character along its
    // track, which is a statement about the cone tip against the curved surface at every point of
    // the path, not about one ratio at greatest eclipse: our ratio for the April 2023 hybrid is
    // 1.014, on the total side, and no threshold separates that from a merely deep annular without
    // relabelling half the canon. So the geometry reports total, annular or partial, and flags the
    // knife edge. The published canon supplies the word where it differs, through `applyCanon` at
    // build time, which is the whole reason the eclipse block is shipped rather than scanned.
    const type = !central ? 'partial' : ratio > 1 ? 'total' : 'annular';
    const mag = central ? ratio : (sM + sS - g.sep) / (2 * sS);
    return { kind: 'eclipse', of: 'solar', type, jd: g.jd, sep: g.sep, gamma, node,
      knife: central && Math.abs(ratio - 1) < 0.02, mag: Math.max(0, mag), lon: norm360(s.lon) };
  }
  // Earth's shadow at the Moon's distance: penumbral and umbral radii, both enlarged for the air.
  const rho = ATMO * (piM + piS + sS), sigma = ATMO * (piM + piS - sS);
  const d = g.sep;
  const type = d < sigma - sM ? 'total' : d < sigma + sM ? 'partial' : d < rho + sM ? 'penumbral' : null;
  if (!type) return null;
  return { kind: 'eclipse', of: 'lunar', type, jd: g.jd, sep: d, gamma: d / piM, node,
    mag: (sigma + sM - d) / (2 * sM), penMag: (rho + sM - d) / (2 * sM), lon: norm360(m.lon) };
}

// Every syzygy in a window, promoted to an eclipse where it is one. The syzygy roots come from the
// one scanner; only the classification is ours.
function eclipsesIn(spec) {
  const targets = floorTargets({ bodies: ['Sun', 'Moon'], aspects: [0, 180] })
    .filter((t) => t.kind === 'syzygy' && (t.angle === 0 || t.angle === 180));
  const roots = scanTargets({ targets, jdStart: spec.jdStart, jdEnd: spec.jdEnd,
    probe: spec.probe, bodyProbe: spec.bodyProbe, step: 0.2 });
  const out = [];
  for (const r of roots) {
    const kind = r.target.angle === 0 ? 'solar' : 'lunar';
    const e = eclipseAt(r.jd, kind, spec);
    if (e) out.push(Object.assign({ layer: 'floor', body: kind === 'solar' ? 'Sun' : 'Moon',
      other: kind === 'solar' ? 'Moon' : 'Sun', enter: e.jd, hinge: e.jd, exit: e.jd }, e));
  }
  return out;
}

// The canon has the last word. Our geometry finds every eclipse and dates it, and it separates
// total from annular from partial, but it does not claim hybrid (see eclipseAt). So the build diffs
// against the published canon over whatever span the canon covers, takes the canon's word for the
// type, and reports what it could not match. Runtime never does this: by then the words are packed.
function applyCanon(eclipses, canon, opts = {}) {
  const tol = opts.tol != null ? opts.tol : 0.7;   // days
  const used = new Set(), missed = [], corrected = [];
  for (const entry of canon) {
    const [iso, type, of] = entry;
    const jdC = jdOfIso(iso);
    let best = -1, bd = tol;
    eclipses.forEach((e, i) => {
      if (used.has(i) || (of && e.of !== of)) return;
      const d = Math.abs(e.jd - jdC);
      if (d < bd) { bd = d; best = i; }
    });
    if (best < 0) { missed.push(iso + ' ' + type); continue; }
    used.add(best);
    const e = eclipses[best];
    if (e.type !== type) corrected.push(iso + ' ' + e.type + ' \u2192 ' + type);
    e.type = type; e.canon = true;
  }
  const unmatched = eclipses.filter((e, i) => !used.has(i));
  return { rows: eclipses, missed, corrected, unmatched };
}
function jdOfIso(iso) {
  const y = +iso.slice(0, 4), mo = +iso.slice(5, 7), d = +iso.slice(8, 10);
  // Local re-derivation of the civil-to-JD conversion, so the reader path stays free of ephem.
  let Y = y, M = mo;
  if (M <= 2) { Y -= 1; M += 12; }
  const A = Math.floor(Y / 100), B = 2 - A + Math.floor(A / 4);
  return Math.floor(365.25 * (Y + 4716)) + Math.floor(30.6001 * (M + 1)) + (d + 0.5) + B - 1524.5;
}

// ---------- the codec ----------
// A shipped table is bytes, not JSON. Four hundred years of the floor is about 310,000 rows, and as
// arrays of decimal numbers that is 7 MB of commas and sentinels; as a varint byte stream it is
// under a fifth of that, with nothing lost. Times are delta-encoded in MINUTES from the span's start
// (finer than the ephemeris deserves) and longitudes in hundredths of a degree. Dictionaries carry
// the words, so a row on the wire is a header byte and a handful of varints, and the row layout
// differs PER KIND because a sentinel for a field a kind does not have is a byte spent on nothing.
const KINDS = ['ingress', 'station', 'retrograde', 'syzygy', 'eclipse', 'aspect'];
const ECL_TYPES = ['total', 'annular', 'hybrid', 'partial', 'penumbral'];
const SYZ_ANG = [0, 90, 180, -90];
const idx = (list, v) => { const i = list.indexOf(v); return i < 0 ? 0 : i; };
const B64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

function W() { this.b = []; }
W.prototype.u = function (v) { v = Math.max(0, Math.round(v)); while (v > 127) { this.b.push((v & 127) | 128); v = Math.floor(v / 128); } this.b.push(v); };
W.prototype.z = function (v) { v = Math.round(v); this.u(v < 0 ? -2 * v - 1 : 2 * v); };
W.prototype.byte = function (v) { this.b.push(v & 255); };
function R(bytes) { this.a = bytes; this.p = 0; }
R.prototype.u = function () { let v = 0, sh = 1, c; do { c = this.a[this.p++]; v += (c & 127) * sh; sh *= 128; } while (c & 128); return v; };
R.prototype.z = function () { const v = this.u(); return v & 1 ? -(v + 1) / 2 : v / 2; };
R.prototype.byte = function () { return this.a[this.p++]; };

function toB64(bytes) {
  let out = '';
  for (let i = 0; i < bytes.length; i += 3) {
    const a = bytes[i], b = bytes[i + 1], c = bytes[i + 2];
    out += B64[a >> 2] + B64[((a & 3) << 4) | ((b || 0) >> 4)]
      + (b === undefined ? '=' : B64[((b & 15) << 2) | ((c || 0) >> 6)])
      + (c === undefined ? '=' : B64[c & 63]);
  }
  return out;
}
function fromB64(str) {
  const clean = str.replace(/=+$/, ''), out = new Uint8Array(Math.floor(clean.length * 3 / 4));
  let o = 0, acc = 0, bits = 0;
  for (let i = 0; i < clean.length; i++) {
    acc = (acc << 6) | B64.indexOf(clean[i]); bits += 6;
    if (bits >= 8) { bits -= 8; out[o++] = (acc >> bits) & 255; }
  }
  return out;
}

// header byte: kind in the low 3 bits, body in the next 4, one flag bit on top (retrograde for an
// ingress, retrograde for a station, lunar for an eclipse).
function packEmbryo(rows, span) {
  const bodies = BODIES.slice();
  const sorted = rows.slice().sort((a, b) => a.jd - b.jd);
  const jd0 = span && span.jdStart != null ? span.jdStart : (sorted[0] ? sorted[0].jd : 0);
  const w = new W();
  let prev = 0;
  for (const r of sorted) {
    const k = idx(KINDS, r.kind), b = idx(bodies, r.body);
    const flag = r.kind === 'ingress' ? (r.retro ? 1 : 0)
      : r.kind === 'station' ? (r.dir === 'retrograde' ? 1 : 0)
      : r.kind === 'eclipse' ? (r.of === 'lunar' ? 1 : 0) : 0;
    w.byte(k | (b << 3) | (flag << 7));
    const t = Math.round((r.jd - jd0) * 1440);
    w.u(t - prev); prev = t;
    const lon = () => w.u(Math.round(norm360(r.lon != null ? r.lon : 0) * 100));
    if (r.kind === 'ingress') w.byte(r.to ? r.to.sign : signIndex(r.lon || 0));
    else if (r.kind === 'station') lon();
    else if (r.kind === 'retrograde') { w.u(Math.round(r.days * 100)); w.u(Math.round(norm360(r.from.lon) * 100)); w.u(Math.round(norm360(r.to.lon) * 100)); }
    else if (r.kind === 'syzygy') { w.byte(idx(SYZ_ANG, r.angle)); lon(); }
    else if (r.kind === 'eclipse') { w.byte(idx(ECL_TYPES, r.type) | (r.knife ? 8 : 0) | (r.canon ? 16 : 0)); w.z(Math.round(r.mag * 1000)); w.u(Math.round(Math.abs(r.gamma) * 1000)); w.z(Math.round(r.node * 100)); lon(); }
    else { w.byte(idx(bodies, r.other)); w.z(r.angle != null ? r.angle : 0); lon(); }
  }
  return { v: 2, jd0, n: sorted.length, bodies, kinds: KINDS, eclTypes: ECL_TYPES, syzAng: SYZ_ANG,
    span: span ? { jdStart: span.jdStart, jdEnd: span.jdEnd, y0: span.y0, y1: span.y1 } : null,
    data: toB64(w.b) };
}

const side = (sign) => ({ sign, signName: SIGNS[sign], dispositor: RULERS[sign], lon: sign * 30 });

// Two passes, and the split is the point: the INDEX pass walks the byte stream once to learn where
// every row starts and when it happens, and the DECODE pass touches only the rows a reader asked
// for. Reading a week of a four-century table costs a week's worth of work.
function index(p) {
  if (p._ix) return p._ix;
  const bytes = fromB64(p.data), r = new R(bytes);
  const jds = new Float64Array(p.n), off = new Int32Array(p.n), hdr = new Uint8Array(p.n);
  let t = 0;
  for (let i = 0; i < p.n; i++) {
    const h = r.byte();
    t += r.u();
    jds[i] = p.jd0 + t / 1440; hdr[i] = h; off[i] = r.p;
    const k = h & 7, kind = p.kinds[k];
    if (kind === 'ingress') r.byte();
    else if (kind === 'station') r.u();
    else if (kind === 'retrograde') { r.u(); r.u(); r.u(); }
    else if (kind === 'syzygy') { r.byte(); r.u(); }
    else if (kind === 'eclipse') { r.byte(); r.z(); r.u(); r.z(); r.u(); }
    else { r.byte(); r.z(); r.u(); }
  }
  const ix = { bytes, jds, off, hdr };
  Object.defineProperty(p, '_ix', { value: ix, enumerable: false });
  return ix;
}

function unpackRow(p, i) {
  const ix = index(p), h = ix.hdr[i], jd = ix.jds[i];
  const kind = p.kinds[h & 7], body = p.bodies[(h >> 3) & 15], flag = h >> 7;
  const r = new R(ix.bytes); r.p = ix.off[i];
  const rec = { layer: 'floor', kind, body, jd, enter: jd, hinge: jd, exit: jd };
  if (kind === 'ingress') {
    rec.retro = !!flag;
    const to = r.byte(), from = (to + (flag ? 1 : 11)) % 12;
    rec.to = side(to); rec.from = side(from);
    rec.boundary = to * 30;
    rec.governed = rec.from.dispositor !== rec.to.dispositor;
  } else if (kind === 'station') { rec.dir = flag ? 'retrograde' : 'direct'; rec.lon = r.u() / 100; }
  else if (kind === 'retrograde') {
    rec.days = r.u() / 100; rec.exit = jd + rec.days;
    rec.from = { lon: r.u() / 100 }; rec.to = { lon: r.u() / 100 };
    rec.from.sign = signIndex(rec.from.lon); rec.to.sign = signIndex(rec.to.lon);
    rec.from.signName = SIGNS[rec.from.sign]; rec.to.signName = SIGNS[rec.to.sign];
    rec.from.dispositor = RULERS[rec.from.sign]; rec.to.dispositor = RULERS[rec.to.sign];
  } else if (kind === 'syzygy') {
    rec.other = body === 'Moon' ? 'Sun' : 'Moon';
    rec.angle = p.syzAng[r.byte()];
    rec.name = rec.angle === 0 ? 'new moon' : rec.angle === 180 ? 'full moon' : 'quarter';
    rec.lon = r.u() / 100;
  } else if (kind === 'eclipse') {
    const t = r.byte();
    rec.of = flag ? 'lunar' : 'solar';
    rec.other = flag ? 'Sun' : 'Moon';
    rec.type = p.eclTypes[t & 7]; rec.knife = !!(t & 8); rec.canon = !!(t & 16);
    rec.mag = r.z() / 1000; rec.gamma = r.u() / 1000; rec.node = r.z() / 100; rec.lon = r.u() / 100;
  } else {
    rec.other = p.bodies[r.byte()];
    rec.angle = r.z(); rec.name = ASPECT_WORD[Math.abs(rec.angle)] || String(rec.angle);
    rec.lon = r.u() / 100;
  }
  return rec;
}
// BUILT BY WALKING MARKS (rewire step C, 2026-08-03), verbatim of loom's step 1. The words are
// mundane's, the KEY SET is the Ring's. This one is a DECODER dictionary, which makes the old typed
// list worse than a duplicate: the packer writes a zigzag angle and this map turns it back into a
// word, so a mark the Ring gained and this table missed would not throw, it would decode as the bare
// number '135' and ship inside the artifact. Same eleven pairs, same strings, no byte moves.
const ASPECT_TERM = { 0: 'conjunction', 30: 'semisextile', 45: 'semisquare', 60: 'sextile', 72: 'quintile',
  90: 'square', 120: 'trine', 135: 'sesquiquadrate', 144: 'biquintile', 150: 'quincunx', 180: 'opposition' };
const ASPECT_WORD = Object.freeze(Object.fromEntries(MARKS.map((a) => {
  const w = ASPECT_TERM[a];
  if (!w) throw new Error('mundane: the Ring carries mark ' + a + ' and mundane has no word for it');
  return [a, w];
})));

// The reader's only door. Cuts (kinds, bodies, aspects) are applied HERE, at read, never at build:
// the table is materialised generously so that no choice the reader makes can invalidate it.
function readEmbryo(packed, q = {}) {
  if (!packed || !packed.data) return [];
  const p = packed, ix = index(p), jds = ix.jds;
  const a = q.jdStart != null ? q.jdStart : -Infinity, b = q.jdEnd != null ? q.jdEnd : Infinity;
  let lo = 0, hi = jds.length;
  while (lo < hi) { const m = (lo + hi) >> 1; if (jds[m] < a) lo = m + 1; else hi = m; }
  const kinds = q.kinds || null, bodies = q.bodies || null, aspects = q.aspects || null;
  const out = [];
  for (let i = lo; i < jds.length && jds[i] <= b; i++) {
    const h = ix.hdr[i], kind = p.kinds[h & 7];
    if (kinds && !kinds.includes(kind)) continue;
    if (bodies && !bodies.includes(p.bodies[(h >> 3) & 15])) continue;
    const rec = unpackRow(p, i);
    if (bodies && rec.other && !bodies.includes(rec.other)) continue;
    if (aspects && kind === 'aspect' && !aspects.includes(Math.abs(rec.angle))) continue;
    out.push(rec);
  }
  return out;
}

// ---------- the build ----------
// Chunked, and a GENERATOR rather than a callback, because the caller owns the yielding: at engrave
// that is the onboarding's own rhythm, at build time it is a progress bar. Slices are half-open so a
// root on a boundary is emitted once.
const SLICE = 1461;   // four years, about a Mars synodic handful of stations per pass

function* mundaneChunks(spec) {
  const jdStart = spec.jdStart, jdEnd = spec.jdEnd;
  const nSlices = Math.max(1, Math.ceil((jdEnd - jdStart) / (spec.slice || SLICE)));
  let all = [];
  for (let i = 0; i < nSlices; i++) {
    const a = jdStart + i * (spec.slice || SLICE);
    const b = Math.min(jdEnd, a + (spec.slice || SLICE));
    const floor = buildFloor({ jdStart: a, jdEnd: b, probe: spec.probe, bodyProbe: spec.bodyProbe,
      bodies: spec.bodies, aspects: spec.aspects, natalOrb: spec.natalOrb });
    // Syzygies come from the floor already; the eclipse block replaces the ones that are eclipses,
    // so a reader never sees the same instant twice under two names.
    const ecl = eclipsesIn({ jdStart: a, jdEnd: b, probe: spec.probe, bodyProbe: spec.bodyProbe,
      moonState: spec.moonState, sunState: spec.sunState });
    const eclipsed = ecl.map((e) => e.jd);
    const kept = floor.filter((e) => e.kind !== 'syzygy' || !eclipsed.some((j) => Math.abs(j - e.jd) < 0.05));
    const rows = kept.concat(ecl).sort((x, y) => x.jd - y.jd);
    all = all.concat(rows);
    yield { i, n: nSlices, jdStart: a, jdEnd: b, rows, total: all.length };
  }
  return all;
}

// Convenience for tests and short spans. A century is chunked by the caller, never here.
function buildMundane(spec) {
  const it = mundaneChunks(spec);
  let out = [], r = it.next();
  while (!r.done) { out = out.concat(r.value.rows); r = it.next(); }
  return out.sort((a, b) => a.jd - b.jd);
}

window.__ORBO_MUNDANE = { EMBRYO_SPAN, angSep, eclipseAt, eclipsesIn, applyCanon, KINDS, packEmbryo, unpackRow, readEmbryo, SLICE, mundaneChunks, buildMundane };
})();
