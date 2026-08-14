// fertilize.browser.js — auto-generated browser-global build of fertilize.js (no ES modules; assigns window.__ORBO_FERT).
// Source of truth is fertilize.js — regenerate this file if fertilize.js changes, don't hand-edit.
// Load order: after loom.browser.js and ring.browser.js.
(function boot(){
if(!window.__ORBO_FRAMING || !window.__ORBO_LOOM || !window.__ORBO_RING){return void setTimeout(boot,0);}
const { BODIES, SIGNS, RULERS, signIndex, norm360, wrap180, synOrb } = window.__ORBO_FRAMING;
const { buildContact, buildSynchronic } = window.__ORBO_LOOM;
const { MARKS } = window.__ORBO_RING;
// fertilize.js — Phase 5 · S4 · fertilization.
//
// Orbo ships the embryo: the sky's own event table, 1700 to 2100, native-independent and
// byte-identical for every reader. The native enters their data and FERTILIZES it. Two weaves come
// out of that one act, a century each: CONTACT (a transiting body touches a natal degree, and the two
// remain two) and SYNCHRONIC (the two become one placement at the midpoint). This file is that act,
// and nothing else: it owns the span, the chunking, the packing and the read cuts. It does not scan.
// loom.js scans.
//
// THE WORD IS SYNCHRONIC (step 7b, 2026-08-04). An earlier pass called this layer "union", a word
// invented for a layer that already had a name. The tag rides inside the stored bytes, so this is the
// one rename that costs a rebuild, and CODEC was deliberately held at 1 through step J to spend it
// exactly once.
//
// THE MIDPOINT IS PRIMARY. Nothing here describes the synchronic layer as the transiting layer
// "halved"; the factor of two lives in the target algebra and nowhere else.
//
// THE SINGLE-DOOR LAW. No ephem import. The caller hands in probe/bodyProbe (spine.probe,
// spine.bodyProbe) and the sky is reached through those alone.
//
// MATERIALISE GENEROUSLY, FILTER AT READ. The build runs with every body, every aspect and the
// WIDEST orb, and every windowed row carries its half-width at that orb. ♊ Bodies, ♍ Aspects and ♍
// Orb are then read-time cuts (`readWeave`), so a reader's choice can never invalidate a century of
// work. Only a change to the natal chart itself, or to doctrine that alters it, forces a rebuild —
// which is exactly what the cache key says.
//
// THE INSTRUMENT SURVIVES EVERYTHING. The build is optional. It is a generator, so the caller owns
// every yield point; a caller that throws mid-build loses the weave and never the plate.
// The Ring is the floor and imports nothing, so depending on it adds no cycle. Angles only:
// the span, the cache key and the codec's dictionaries are this file's own and stay here.

// Birth minus a year (the prenatal sky is already in play by the time a life is read) to birth plus a
// century, clamped to whatever bounds the ephemeris admits.
const FERT = { pre: 365.25, years: 100, slice: 90, orb: 10 };
const WEAVES = ['contact', 'synchronic'];
// The dictionary of contactable natal points: the bodies, plus the two angles contactTargets adds.
const TARGETS = BODIES.concat(['Asc', 'Mc']);
const KINDS_W = ['aspect', 'ingress', 'flip'];
const idx = (list, v) => { const i = list.indexOf(v); return i < 0 ? 0 : i; };

function fertSpan(natalJd, bounds = {}) {
  const lo = bounds.jdMin != null ? bounds.jdMin : -Infinity;
  const hi = bounds.jdMax != null ? bounds.jdMax : Infinity;
  const pre = bounds.pre != null ? bounds.pre : FERT.pre;
  const years = bounds.years != null ? bounds.years : FERT.years;
  return { jdStart: Math.max(lo, natalJd - pre), jdEnd: Math.min(hi, natalJd + years * 365.25) };
}

// The cache key. Natal identity plus the doctrine fingerprint plus the codec version: a re-engraved
// seed, a doctrine change that moves the chart, or a new row layout all miss, and nothing else does.
//
// CHART IDENTITY IS THE GENOME (rewire step G, 2026-08-04). This used to be natal.jd to six decimals
// plus fifteen positions to three, which is a TIMESTAMP identity with floats bolted on: two moments
// that engrave the same genome ARE the same chart, and two derivations of one chart that wobble in
// the ninth decimal are not two charts. So the preferred key is the sequence string, and the float
// fingerprint stays as a documented FALLBACK for callers with no genome (the test harnesses build a
// natal by hand). What the genome does not carry that the old key did is the MC and the extras; both
// are deterministic functions of the same instant and place, and a collision needs two births whose
// every node agrees to the whole degree, which doctrine says is the same chart.
//
// `natal.seq` MUST BE THE DEGREE PROJECTION, never the raw genome (arcsecond widening, SEQ_CODEC 3,
// 2026-08-04). The gene is arcseconds of the circle now, and a key is a deliberate cut at the
// resolution the artifact's contents are sensitive to: a century of scanning does not move for one
// arcsecond, so keying on the full genome would discard every reader's weave on a float wiggle in the
// ninth decimal. Callers pass `astrodna.degreeSequenceString(dna)`, which is byte-identical to what
// `sequenceString` returned under codec 2 — which is why the widening rebuilt nothing. Nothing here
// changed and CODEC moves to 2 for the "union" to "synchronic" rename, which is the one change to
// this file's stored bytes that the rename could not avoid (§3 of the 7b prompt: accept one rebuild,
// and do not try to be clever about it).
const CODEC = 2;
function fertKey(natal, doctrineKey) {
  const id = natal.seq
    ? 'g' + natal.seq
    : 'f' + (natal.jd != null ? natal.jd.toFixed(6) : '') + '|' + TARGETS.map((b) => {
      const v = b === 'Asc' ? natal.asc : b === 'Mc' ? natal.mc : natal.pos[b];
      return v == null ? '' : v.toFixed(3);
    }).join(',');
  return 'w' + CODEC + '|' + id + '|' + (doctrineKey || '');
}

// ---------- the build ----------
// A GENERATOR, because the caller owns the yielding: at engrave that is the onboarding's own rhythm,
// on a bench it is a progress bar. Every yield carries enough to narrate without knowing anything
// about the loom. Slices are half-open, so a root on a boundary is emitted once.
function* fertilizeChunks(natal, spec) {
  const span = spec.jdStart != null ? { jdStart: spec.jdStart, jdEnd: spec.jdEnd }
    : fertSpan(natal.jd, spec);
  const slice = spec.slice || FERT.slice;
  const layers = spec.layers || WEAVES;
  const nPer = Math.max(1, Math.ceil((span.jdEnd - span.jdStart) / slice));
  const nAll = nPer * layers.length;
  const opts = { bodies: spec.bodies || BODIES, aspects: spec.aspects || [0, 60, 90, 120, 180],
    natalOrb: spec.natalOrb != null ? spec.natalOrb : FERT.orb,
    probe: spec.probe, bodyProbe: spec.bodyProbe };
  const rows = [];
  let done = 0;
  for (const layer of layers) {
    for (let i = 0; i < nPer; i++) {
      const a = span.jdStart + i * slice, b = Math.min(span.jdEnd, a + slice);
      const build = layer === 'synchronic' ? buildSynchronic : buildContact;
      const got = build(natal, { ...opts, jdStart: a, jdEnd: b });
      for (const r of got) rows.push(r);
      done++;
      yield { layer, i, n: nPer, step: done, steps: nAll, pct: done / nAll,
        jdStart: a, jdEnd: b, rows: got, total: rows.length, span };
    }
  }
  rows.sort((x, y) => x.jd - y.jd);
  return { rows, span, natalOrb: opts.natalOrb, aspects: opts.aspects };
}

// Convenience: run the whole thing on one stack. For tests and short spans only. A century is
// chunked by the caller, always, or onboarding stalls.
function fertilize(natal, spec) {
  const it = fertilizeChunks(natal, spec);
  let r = it.next();
  while (!r.done) r = it.next();
  return r.value;
}

// The same build with the event loop given back between slices, which is what an engrave actually
// wants. onProgress is handed each yield verbatim; a truthy `cancel()` abandons the build.
async function fertilizeAsync(natal, spec = {}) {
  const it = fertilizeChunks(natal, spec);
  const idle = spec.idle || ((fn) => setTimeout(fn, 0));
  let r = it.next();
  while (!r.done) {
    if (spec.onProgress) spec.onProgress(r.value);
    if (spec.cancel && spec.cancel()) return null;
    await new Promise((res) => idle(res));
    r = it.next();
  }
  return r.value;
}

// ---------- the codec ----------
// Bytes, not JSON, for the same reason the embryo is bytes: a century of two weaves as decimal
// arrays is megabytes of commas, and IDB holds two of these per native. Times are delta-encoded in
// MINUTES from the span's start, longitudes in hundredths of a degree, and every reading that can be
// DERIVED is derived at read (sign names, dispositors, houses, aspect words, whether the government
// changed) rather than stored twelve times over.
function W() { this.b = []; }
W.prototype.u = function (v) { v = Math.max(0, Math.round(v)); while (v > 127) { this.b.push((v & 127) | 128); v = Math.floor(v / 128); } this.b.push(v); };
W.prototype.z = function (v) { v = Math.round(v); this.u(v < 0 ? -2 * v - 1 : 2 * v); };
W.prototype.byte = function (v) { this.b.push(v & 255); };
function R(bytes) { this.a = bytes; this.p = 0; }
R.prototype.u = function () { let v = 0, sh = 1, c; do { c = this.a[this.p++]; v += (c & 127) * sh; sh *= 128; } while (c & 128); return v; };
R.prototype.z = function () { const v = this.u(); return v & 1 ? -(v + 1) / 2 : v / 2; };
R.prototype.byte = function () { return this.a[this.p++]; };
const B64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
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

// header byte: kind in bits 0-1, layer in bit 2, body in bits 3-6, retrograde in bit 7.
function packWeave(built, meta = {}) {
  const rows = (built.rows || built).slice().sort((a, b) => a.jd - b.jd);
  const span = built.span || meta.span || {};
  const jd0 = span.jdStart != null ? span.jdStart : (rows[0] ? rows[0].jd : 0);
  const natal = meta.natal || {};
  const w = new W();
  let prev = 0;
  for (const r of rows) {
    const k = idx(KINDS_W, r.kind), b = idx(BODIES, r.body);
    w.byte(k | ((r.layer === 'synchronic' ? 1 : 0) << 2) | (b << 3) | (r.retro ? 128 : 0));
    const t = Math.round((r.jd - jd0) * 1440);
    w.u(t - prev); prev = t;
    const half = () => w.u(Math.max(0, Math.round((r.exit - r.jd) * 1440)));
    const lon = (v) => w.u(Math.round(norm360(v || 0) * 100));
    if (r.kind === 'ingress') {
      w.byte((r.to ? r.to.sign : signIndex(r.lon || 0)) | ((r.phase ? 1 : 0) << 4));
    } else if (r.kind === 'flip') {
      w.byte((r.to ? r.to.sign : signIndex(r.lon || 0)) | ((r.phase ? 1 : 0) << 4));
      half();
    } else {
      w.byte(idx(TARGETS, r.other));
      w.z(r.angle != null ? r.angle : 0);
      half();
      lon(r.lon != null ? r.lon : 0);
      if (r.layer === 'synchronic') {
        lon(r.bSide ? r.bSide.lon : 0);
        w.byte((r.aSide && r.aSide.phase ? 1 : 0) | ((r.phase ? 1 : 0) << 1));
      }
    }
  }
  return { v: CODEC, jd0, n: rows.length, kinds: KINDS_W, bodies: BODIES.slice(), targets: TARGETS.slice(),
    span: { jdStart: span.jdStart, jdEnd: span.jdEnd },
    natal: { jd: natal.jd, asc: natal.asc },
    natalOrb: built.natalOrb != null ? built.natalOrb : (meta.natalOrb != null ? meta.natalOrb : FERT.orb),
    aspects: built.aspects || meta.aspects || null,
    key: meta.key || null,
    data: toB64(w.b) };
}

// Two passes, same split as the embryo: INDEX walks the byte stream once to learn where each row
// starts and when it happens, DECODE touches only the rows the reader asked for.
function index(p) {
  if (p._ix) return p._ix;
  const bytes = fromB64(p.data), r = new R(bytes);
  const jds = new Float64Array(p.n), off = new Int32Array(p.n), hdr = new Uint8Array(p.n);
  let t = 0;
  for (let i = 0; i < p.n; i++) {
    const h = r.byte();
    t += r.u();
    jds[i] = p.jd0 + t / 1440; hdr[i] = h; off[i] = r.p;
    const kind = p.kinds[h & 3], syn = !!((h >> 2) & 1);
    if (kind === 'ingress') r.byte();
    else if (kind === 'flip') { r.byte(); r.u(); }
    else { r.byte(); r.z(); r.u(); r.u(); if (syn) { r.u(); r.byte(); } }
  }
  const ix = { bytes, jds, off, hdr };
  Object.defineProperty(p, '_ix', { value: ix, enumerable: false });
  return ix;
}

// BUILT BY WALKING MARKS (rewire step C, 2026-08-03). The second of the two DECODER dictionaries,
// and the one with the longest fuse: mundane's wrong word would at least be built once, in one
// artifact, in front of whoever ran the build. This weave is rebuilt PER CHART and persisted in
// IndexedDB under fertKey, so a mark the Ring gained and this table missed would decode as the bare
// number '135', get cached in the reader's own browser, and survive every later fix until the key
// changed. Same eleven pairs, same strings, no byte moves.
const ASPECT_TERM = { 0: 'conjunction', 30: 'semisextile', 45: 'semisquare', 60: 'sextile', 72: 'quintile',
  90: 'square', 120: 'trine', 135: 'sesquiquadrate', 144: 'biquintile', 150: 'quincunx', 180: 'opposition' };
const ASPECT_WORD = Object.freeze(Object.fromEntries(MARKS.map((a) => {
  const w = ASPECT_TERM[a];
  if (!w) throw new Error('fertilize: the Ring carries mark ' + a + ' and fertilize has no word for it');
  return [a, w];
})));
// Houses are natal whole-sign, anchored to the natal ASC SIGN, always. A synchronic placement is
// never re-housed from a derived ascendant.
function sideOf(lon, ascSign) {
  const sg = signIndex(lon), s = { lon: norm360(lon), sign: sg, signName: SIGNS[sg], dispositor: RULERS[sg] };
  if (ascSign != null) s.house = ((sg - ascSign) + 12) % 12 + 1;
  return s;
}

function unpackWeaveRow(p, i) {
  const ix = index(p), h = ix.hdr[i], jd = ix.jds[i];
  const kind = p.kinds[h & 3], layer = ((h >> 2) & 1) ? 'synchronic' : 'contact';
  const body = p.bodies[(h >> 3) & 15], retro = !!(h >> 7);
  const ascSign = p.natal && p.natal.asc != null ? signIndex(p.natal.asc) : null;
  const r = new R(ix.bytes); r.p = ix.off[i];
  const rec = { jd, layer, kind, body, retro, enter: jd, hinge: jd, exit: jd };
  if (kind === 'ingress' || kind === 'flip') {
    const byt = r.byte(), to = byt & 15;
    rec.phase = (byt >> 4) & 1;
    // Direction picks which reading is which (the v0.878 retrograde fix): direct, the boundary
    // crossed is the start of the sign entered; retrograde, the start of the sign being LEFT.
    const from = (to + (retro ? 1 : 11)) % 12;
    rec.to = sideOf(to * 30 + 15, ascSign); rec.from = sideOf(from * 30 + 15, ascSign);
    rec.to.lon = to * 30; rec.boundary = to * 30;
    // The three readings do NOT always change together: synchronic Saturn crosses 29°56' Capricorn
    // into 0°00' Aquarius with no change of dispositor at all.
    rec.governed = rec.from.dispositor !== rec.to.dispositor;
    if (kind === 'flip') {
      // A flip IS transiting P opposing natal P: on the contact layer the row's other end is the
      // native's own placement, so it is derived, never stored.
      if (layer === 'contact') { rec.other = body; rec.target = body; }
      // A flip is a WINDOW, not a hinge: approach, hinge, departure. Retrograde stutter is three
      // events, each with its own window, and the overlap through the station is the signature.
      const half = r.u() / 1440;
      rec.enter = jd - half; rec.exit = jd + half;
      rec.orbHalf = half;
    }
  } else {
    rec.other = p.targets[r.byte()];
    rec.angle = r.z(); rec.name = ASPECT_WORD[Math.abs(rec.angle)] || String(rec.angle);
    const half = r.u() / 1440;
    rec.enter = jd - half; rec.exit = jd + half; rec.orbHalf = half;
    rec.lon = r.u() / 100;
    if (layer === 'synchronic') {
      const bl = r.u() / 100, ph = r.byte();
      rec.aSide = sideOf(rec.lon, ascSign); rec.aSide.phase = ph & 1;
      rec.bSide = sideOf(bl, ascSign); rec.bSide.phase = (ph >> 1) & 1;
      rec.phase = (ph >> 1) & 1;
      // No `serves` (step 7b). One root no longer stands for an aspect and its supplement, because
      // every admitted angle is its own target now, so the stored angle IS the reading: the Ring
      // decreed it at exact, at build, and there is nothing left to choose at read.
    } else {
      rec.target = rec.other;
    }
  }
  return rec;
}

// The reader's only door. Every cut is applied HERE: kinds, layers, bodies, aspects, and the orb.
// Windows were stored at the build's widest orb, and an orb is linear in the residual, so a narrower
// orb is the same window scaled. Nothing is rescanned and nothing is invalidated.
function readWeave(packed, q = {}) {
  if (!packed || !packed.data) return [];
  const p = packed, ix = index(p), jds = ix.jds;
  const a = q.jdStart != null ? q.jdStart : -Infinity, b = q.jdEnd != null ? q.jdEnd : Infinity;
  let lo = 0, hi = jds.length;
  while (lo < hi) { const m = (lo + hi) >> 1; if (jds[m] < a) lo = m + 1; else hi = m; }
  const kinds = q.kinds || null, layers = q.layers || null, bodies = q.bodies || null, aspects = q.aspects || null;
  const wide = p.natalOrb != null ? p.natalOrb : FERT.orb;
  const out = [];
  for (let i = lo; i < jds.length && jds[i] <= b; i++) {
    const h = ix.hdr[i], kind = p.kinds[h & 3], layer = ((h >> 2) & 1) ? 'synchronic' : 'contact';
    if (kinds && !kinds.includes(kind)) continue;
    if (layers && !layers.includes(layer)) continue;
    if (bodies && !bodies.includes(p.bodies[(h >> 3) & 15])) continue;
    const rec = unpackWeaveRow(p, i);
    if (bodies && rec.other && !bodies.includes(rec.other) && rec.other !== 'Asc' && rec.other !== 'Mc') continue;
    if (aspects && kind === 'aspect' && !aspects.includes(Math.abs(rec.angle))) continue;
    if (q.orb != null && rec.orbHalf) {
      // The synchronic orb is not doubled here (step 7b): the window was scanned in the occupant's
      // own units, so orb and rate are in the same units on both sides. This was always a ratio, so
      // the old pair of factors cancelled and no stored window moves.
      const want = layer === 'synchronic' ? synOrb(Math.abs(rec.angle) || 0, q.orb)
        : (kind === 'flip' ? Math.min(q.orb, 2) : q.orb);
      const at = layer === 'synchronic' ? synOrb(Math.abs(rec.angle) || 0, wide) : (kind === 'flip' ? Math.min(wide, 2) : wide);
      const f = at > 0 ? Math.min(1, want / at) : 1;
      rec.enter = rec.jd - rec.orbHalf * f; rec.exit = rec.jd + rec.orbHalf * f;
      if (q.at != null && (q.at < rec.enter || q.at > rec.exit)) continue;
    }
    out.push(rec);
  }
  return out;
}

// What a native's fertilized table costs, for the bench and for the cache's own honesty.
function weaveStats(packed) {
  if (!packed) return null;
  const bytes = Math.round(packed.data.length * 3 / 4);
  return { rows: packed.n, bytes, perRow: packed.n ? bytes / packed.n : 0,
    span: packed.span, natalOrb: packed.natalOrb };
}

window.__ORBO_FERT = { FERT, WEAVES, TARGETS, fertSpan, CODEC, fertKey, fertilizeChunks, fertilize, fertilizeAsync, packWeave, unpackWeaveRow, readWeave, weaveStats };
})();
