// loom.browser.js — auto-generated browser-global build of loom.js (no ES modules; assigns window.__ORBO_LOOM).
// Source of truth is loom.js — regenerate this file if loom.js changes, don't hand-edit.
// Load order: after framing.browser.js and ring.browser.js.
(function boot(){
// Bundle-safety: inlined blob scripts don't preserve <script> order, so wait for deps
// (see CLAUDE.md — browser-build-only guard, no analog in the ES-module source).
if(!window.__ORBO_FRAMING||!window.__ORBO_RING){return void setTimeout(boot,0);}
const { norm360, wrap180, midpoint, refract, signIndex, phaseOf, mod180, RULERS, SIGNS, BODIES, floorTargets, contactTargets, synchronicTargets, synOrb } = window.__ORBO_FRAMING;
const { MARKS, nearest, separation } = window.__ORBO_RING;
// loom.js — Phase 5 · the one scanner.
//
// Two threads, two weaves. The sky thread is the mundane FLOOR: native-independent, place-free,
// byte-identical for every reader. The native thread is the engraved chart. They weave by CONTACT
// (a transiting body touches a natal degree, and the two remain two) and SYNCHRONICALLY (the two
// become one placement at the midpoint). Three layers, ONE scanner: they differ only in what counts
// as a target, and the target algebra lives in framing.js. There is no synchronic spine in here,
// only a third target set.
//
// THE MIDPOINT IS PRIMARY. The synchronic layer is never the transiting layer "halved".
//
// EVERYTHING IN ORBO EXISTS ON THE RING (step 7b, 2026-08-04). This file used to scan in SKY space,
// pulling a synchronic target back through a coordinate change so the scanner could stay ignorant of
// it. That is gone. A target's degree is a degree of its OWN OCCUPANT, and an occupant is a body
// optionally measured from a natal degree (see lonAt below): that one composition is the whole of
// what this file knows about the layers, and it is a restatement of the Ring's own law that `layer`
// is not a geometry but which occupant is sitting there, differing only in SPEED.
//
// TWO THINGS THE PULLBACK WAS CREDITED WITH, AND WHAT ACTUALLY CARRIES THEM NOW:
//   1. The phase gate. It is not replaced by a continuous coordinate, it is UNNECESSARY: the
//      displayed point jumps 180 degrees at a flip, so it arrives here as an ordinary WRAP, and the
//      wrap guard in the sample loop has handled wraps on every layer since S1. The `d > 150`
//      heuristic and its successor parity gate are both answered by that one guard. Measured before
//      the deletion: 128 ingresses, 19 flips, 147 contacts on the fixture natal, every root paired
//      with the pullback's at max delta 0.00 minutes. Do NOT reintroduce a parity bit to help it.
//   2. Stations are shared. A synchronic placement is stationary exactly when its sky body is, at the
//      same instant, so the floor's station roots serve all three layers and nothing rescans them.
//      That is why 'speed' reads the sky body directly and never an occupant.
//
// THE SINGLE-DOOR LAW. This file never imports ephem in the app path. It is handed a probe
// (spine.probe) and reads the sky through that alone.
// The Ring is the floor and imports nothing, so depending on it adds no cycle. Angles only: the die
// for the words below, and `nearest`/`separation` because THE RING DECREES THE ASPECT AT EXACT.

// Grid coarseness per body, in days: fine enough that no target's residual changes by more than
// about a quarter turn between samples, coarse enough that a century is affordable. Keyed on the SKY
// body's rate, which is the fastest an occupant on it can move: a synchronic placement travels at
// half that, so the same grid is conservative for it rather than needing a table of its own.
const STEP_FOR = { Moon: 0.15, Sun: 0.5, Mercury: 0.35, Venus: 0.5, Mars: 0.6, Jupiter: 1.5,
  Saturn: 2, Uranus: 3, Neptune: 4, Pluto: 4, Node: 2, SNode: 2, Chiron: 3, Lilith: 0.6 };
function stepFor(body, mode) {
  const s = STEP_FOR[body] || 1;
  return mode === 'speed' ? Math.max(0.25, s * 0.5) : s;
}
// Confirmation distance, in degrees of the SKY residual: a root is PENDING until the body takes up
// residence past it. Without this, a body librating on a target emits every wobble as an event (the
// v0.878 Node-on-the-cusp bug). The synchronic figure is v0.878's own 0.1 degrees, back in the
// coordinate it was written in now that the scan runs in the occupant's own space. A flip's root is a
// sky-space root by nature, so its target carries the same law doubled (framing.SYN_CONFIRM).
const CONFIRM = { floor: 0.05, contact: 0.05, synchronic: 0.1 };
// A station is the one root that must NOT be confirmed by residency, and confirming it was a real
// bug: the residual there is a SPEED, in degrees per day, so 0.05 asks a body to be moving twenty
// times faster than Saturn ever moves retrograde before its station counts. Saturn stationing on 31
// March 1987 was silently dropped from any window ending before mid-May, while a four-year slice
// found it, which is how a shipped table and a live scan came to disagree. A velocity sign change is
// also not the thing residency guards against: a body cannot wobble across its own station without
// genuinely reversing. So the speed confirmation is a hair off zero, enough to ignore arithmetic
// noise and nothing more.
const CONFIRM_SPEED = 5e-4;
const H = 0.02;   // half-width of the finite difference, in days

// ---------- the scanner ----------
// Returns raw ROOTS: { target, jd, v, retro }. Decoration into records is a separate pass, so the
// scanner knows nothing about signs, houses or dispositors.
//
// The grid is walked ONCE PER GROUP, not once per target: every target on the same body (or the same
// pair) shares one pass over the sky, and a residual is then one subtraction. A century has hundreds
// of targets and a handful of groups, so this is the difference between minutes and seconds.
function scanTargets(spec) {
  const { targets, jdStart, jdEnd, probe } = spec;
  // The light single-body door when the caller has one (spine.bodyProbe), the full genome otherwise.
  const skyAt = spec.bodyProbe ? (jd, b) => spec.bodyProbe(jd, b) : (jd, b) => probe(jd)[b];
  // THE OCCUPANT. A body, optionally measured from a natal degree: no `nat` is the sky itself (the
  // floor and the contact weave), a `nat` is the synchronic placement midpoint(nat, sky). This one
  // line is the entire difference between the layers as far as the scanner is concerned, and the
  // halved rate it implies is the only genuine difference there has ever been. The composition goes
  // through framing.refract, the app's ONE refraction door (Phase 6 · P1).
  const lonAt = (jd, b, nat) => (nat == null ? skyAt(jd, b) : refract(nat, skyAt(jd, b)));
  const groups = new Map();
  for (const t of targets) {
    // The layer and the natal reference join the key: a contact 'lon' target and a synchronic one on
    // the same body differ ONLY by their occupant, so sharing one pass would scan the wrong thing.
    const key = t.layer + '|' + t.mode + '|' + t.body + '|' + (t.other || '')
      + '|' + (t.nat == null ? '' : t.nat.toFixed(6)) + '|' + (t.natOther == null ? '' : t.natOther.toFixed(6));
    let g = groups.get(key);
    if (!g) groups.set(key, g = { mode: t.mode, body: t.body, other: t.other, nat: t.nat, natOther: t.natOther, list: [] });
    g.list.push(t);
  }
  const roots = [];
  for (const g of groups.values()) {
    const step = spec.step || (g.mode === 'sep'
      ? Math.min(stepFor(g.body, g.mode), stepFor(g.other, g.mode))
      : stepFor(g.body, g.mode));
    const base = g.mode === 'sep'
      ? (jd) => wrap180(lonAt(jd, g.body, g.nat) - lonAt(jd, g.other, g.natOther))
      : g.mode === 'speed'
        // A station belongs to the SKY body and is shared by all three layers, so this reads the sky
        // directly and never an occupant.
        ? (jd) => wrap180(skyAt(jd + H, g.body) - skyAt(jd - H, g.body)) / (2 * H)
        : (jd) => lonAt(jd, g.body, g.nat);
    const resid = g.mode === 'speed' ? (b) => b : (b, t) => wrap180(b - t.deg);
    const st = g.list.map((t) => ({ t, f: (jd) => resid(base(jd), t), side: 0, pv: 0, pj: jdStart, pend: null,
      conf: t.confirm != null ? t.confirm : (spec.confirm != null ? spec.confirm : (g.mode === 'speed' ? CONFIRM_SPEED : CONFIRM[t.layer] || 0.05)) }));
    let b0 = base(jdStart);
    for (const s of st) { s.pv = resid(b0, s.t); s.side = Math.sign(s.pv) || 1; }
    for (let jd = jdStart + step; jd <= jdEnd; jd += step) {
      const bv = base(jd);
      for (const s of st) {
        const cv = resid(bv, s.t);
        // THE WRAP GUARD, and it is what deletes the phase gate. A pole jump at a flip moves the
        // displayed point, and any separation involving it, by exactly 180 in one step, so it arrives
        // here as a wrap like any other and needs no parity bit and no special coordinate.
        if (g.mode !== 'speed' && Math.abs(cv - s.pv) > 90) { s.pj = jd; s.pv = cv; s.side = Math.sign(cv) || s.side; s.pend = null; continue; }
        const sg = Math.sign(cv) || s.side;
        if (sg === s.side) { s.pend = null; s.pj = jd; s.pv = cv; continue; }
        if (!s.pend) {
          let lo = s.pj, hi = jd;
          for (let i = 0; i < 44; i++) { const m = (lo + hi) / 2; if ((Math.sign(s.f(m)) || s.side) === s.side) lo = m; else hi = m; }
          const jr = (lo + hi) / 2;
          s.pend = { jd: jr, v: (s.f(jr + H) - s.f(jr - H)) / (2 * H) };
        }
        if (Math.abs(cv) < s.conf) { s.pj = jd; s.pv = cv; continue; }   // not resident yet
        roots.push({ target: s.t, jd: s.pend.jd, v: s.pend.v, retro: s.pend.v < 0 });
        s.side = sg; s.pend = null; s.pj = jd; s.pv = cv;
      }
    }
  }
  return roots.sort((a, b) => a.jd - b.jd);
}

// ---------- decoration ----------
// THE WORDS STAY HERE; THE ANGLES COME FROM THE RING. A word is a meaning and the Ring holds none, so
// the vocabulary is loom's. But the KEY SET is geometry, and it was a second copy of the die: eleven
// literals that agreed with the Ring by inspection and could stop agreeing with it silently. The table
// is now BUILT BY WALKING MARKS, so a non-mark key cannot survive construction and a mark with no word
// throws AT LOAD rather than yielding an undefined name at the one moment a reader is reading. Same
// eleven pairs, same strings, no number moves: verified in tests/rewire-parity.test.html.
const ASPECT_WORD = { 0: 'conjunction', 30: 'semisextile', 45: 'semisquare', 60: 'sextile', 72: 'quintile',
  90: 'square', 120: 'trine', 135: 'sesquiquadrate', 144: 'biquintile', 150: 'quincunx', 180: 'opposition' };
const ASPECT_NAME = Object.freeze(Object.fromEntries(MARKS.map((a) => {
  const w = ASPECT_WORD[a];
  if (!w) throw new Error('loom: the Ring carries mark ' + a + ' and loom has no word for it');
  return [a, w];
})));

function sideOf(lon, natal) {
  const sg = signIndex(lon), s = { lon: norm360(lon), sign: sg, signName: SIGNS[sg], dispositor: RULERS[sg] };
  if (natal) s.house = ((sg - signIndex(natal.asc)) + 12) % 12 + 1;
  return s;
}
// A record carries its window at the WIDEST orb, always, so the reader filters and no filter choice
// ever invalidates the build (♊ Bodies, ♍ Aspects and ♍ Orb are read-time cuts).
function windowFor(root, orbDeg) {
  const v = Math.abs(root.v);
  if (!(v > 1e-9) || !(orbDeg > 0)) return { enter: root.jd, hinge: root.jd, exit: root.jd };
  const w = Math.min(400, orbDeg / v);
  return { enter: root.jd - w, hinge: root.jd, exit: root.jd + w };
}

function decorate(root, ctx = {}) {
  const t = root.target, natal = ctx.natal, probe = ctx.probe;
  const rec = { jd: root.jd, layer: t.layer, kind: t.kind, body: t.body, retro: root.retro };
  if (t.other) rec.other = t.other;
  if (t.angle != null) { rec.angle = t.angle; rec.name = ASPECT_NAME[t.angle] || String(t.angle); }
  // The window is orb over rate, and BOTH are in the occupant's own units now. The doubling that used
  // to sit on synOrb here existed ONLY to compensate for a rate measured in sky space, so removing it
  // alongside the pullback leaves every window byte-identical; leaving it in would silently double
  // every synchronic window.
  const orbWide = ctx.orb != null ? ctx.orb : (t.layer === 'synchronic' ? synOrb(t.angle != null ? t.angle : 0, ctx.natalOrb || 6) : ctx.natalOrb || 6);
  if (t.layer === 'synchronic' && natal) {
    const sky = probe ? probe(root.jd) : null;
    const nl = natal.pos[t.body];
    if (sky) {
      const p = midpoint(nl, sky[t.body]);
      rec.axis = mod180(p); rec.phase = phaseOf(nl, sky[t.body]); rec.lon = norm360(p);
    }
  }
  if (t.kind === 'ingress') {
    const dir = root.retro ? -1 : 1;
    // Direction picks which reading is which, on every layer (the v0.878 retrograde fix): going
    // direct the boundary crossed is the start of the sign being entered, going retrograde it is
    // the start of the sign being LEFT.
    const enteringSign = dir > 0 ? t.sign : (t.sign + 11) % 12;
    const leavingSign = (enteringSign + (dir > 0 ? 11 : 1)) % 12;
    rec.from = sideOf(leavingSign * 30 + 15, t.layer === 'floor' ? null : natal);
    rec.to = sideOf(enteringSign * 30 + 15, t.layer === 'floor' ? null : natal);
    rec.boundary = t.boundary != null ? t.boundary : t.sign * 30;
    // The three readings do NOT always change together. The fixture's synchronic Saturn crosses 29°56'
    // Capricorn into 0°00' Aquarius with no change of dispositor at all, Saturn to Saturn.
    rec.governed = rec.from.dispositor !== rec.to.dispositor;
    Object.assign(rec, { enter: root.jd, hinge: root.jd, exit: root.jd });
  } else if (t.kind === 'flip') {
    // A flip is a WINDOW, not a hinge: approach, hinge, departure. At the hinge neither pole has a
    // privileged claim. Retrograde stutter is three events, each with its own window, and the
    // overlap through the station is the signature. Never smoothed, never collapsed.
    const nl = natal ? natal.pos[t.body] : null, sky = probe ? probe(root.jd) : null;
    Object.assign(rec, windowFor(root, ctx.flipOrb != null ? ctx.flipOrb : 2));
    if (nl != null && sky) {
      const eps = Math.max(1e-4, (rec.exit - rec.enter) / 40);
      rec.from = sideOf(midpoint(nl, probe(root.jd - eps)[t.body]), natal);
      rec.to = sideOf(midpoint(nl, probe(root.jd + eps)[t.body]), natal);
      rec.phase = phaseOf(nl, probe(root.jd + eps)[t.body]);
      rec.governed = rec.from.dispositor !== rec.to.dispositor;
    }
  } else if (t.kind === 'station') {
    rec.dir = root.v > 0 ? 'direct' : 'retrograde';
    Object.assign(rec, { enter: root.jd, hinge: root.jd, exit: root.jd });
    if (probe) rec.lon = norm360(probe(root.jd)[t.body]);
  } else {
    Object.assign(rec, windowFor(root, orbWide));
    if (t.layer === 'synchronic' && t.other) {
      // THE RING DECREES THE ASPECT AT EXACT. At a root the two placements are exactly a mark apart,
      // so nearest is total, single-valued and exact here. This was the LAST piece of nearest-mark
      // arithmetic living outside the Ring: a reduce over a `serves` list, choosing between an aspect
      // and its supplement by hand. Supplement closure is still a fact of the set; what died is the
      // list that conflated a root with its supplement's LABEL, because every admitted angle is now
      // its own target in its own direction and no root is shared by two readings.
      // Falsy-zero: 0 is a conjunction and residual 0 means EXACT, so the read is taken by field.
      if (natal && probe) {
        const sky = probe(root.jd);
        const pa = midpoint(natal.pos[t.body], sky[t.body]), pb = midpoint(natal.pos[t.other], sky[t.other]);
        const n = nearest(separation(pb, pa));
        rec.angle = n.angle; rec.name = ASPECT_NAME[n.angle] || String(n.angle);
        rec.aSide = sideOf(pa, natal); rec.bSide = sideOf(pb, natal);
      }
    } else if (t.layer === 'contact' && natal) {
      rec.target = t.other;
      if (probe) rec.lon = norm360(probe(root.jd)[t.body]);
    } else if (probe) {
      rec.lon = norm360(probe(root.jd)[t.body]);
      if (t.kind === 'syzygy') rec.name = t.angle === 0 ? 'new moon' : t.angle === 180 ? 'full moon' : 'quarter';
    }
  }
  return rec;
}

// ---------- the three builders ----------
function run(targets, spec, ctx) {
  const roots = scanTargets({ ...spec, targets });
  return roots.map((r) => decorate(r, ctx));
}
// The Moon is a cardinality problem, not a difficulty problem: her mutual aspects, her natal
// contacts and her synchronic contacts are ~350k rows per century against ~50k for everything else,
// so they belong to luna.js as a windowed generator and are never materialised. What DOES materialise
// is sparse and structural: her sign ingresses and the syzygies on the floor, her flips and her
// synchronic ingresses on the weave. Never widen this without reading §2 of the plan.
function moonCut(targets, keep) {
  return targets.filter((t) => {
    const touchesMoon = t.body === 'Moon' || t.other === 'Moon';
    if (!touchesMoon) return true;
    return keep.includes(t.kind);
  });
}
// A read cut on the target set, so a caller asking for one kind does not pay to scan the other two.
// Absent means all, which is what every materialising build passes: MATERIALISE GENEROUSLY.
function kindCut(targets, kinds) {
  return Array.isArray(kinds) && kinds.length ? targets.filter((t) => kinds.includes(t.kind)) : targets;
}
function buildFloor(spec) {
  const targets = kindCut(moonCut(floorTargets({ bodies: spec.bodies, aspects: spec.aspects }), ['ingress', 'syzygy', 'station']), spec.kinds);
  return run(targets, spec, { probe: spec.probe, natalOrb: spec.natalOrb });
}
function buildContact(natal, spec) {
  const targets = kindCut(moonCut(contactTargets(natal, { bodies: spec.bodies, aspects: spec.aspects }), []), spec.kinds);
  return run(targets, spec, { probe: spec.probe, natal, natalOrb: spec.natalOrb });
}
function buildSynchronic(natal, spec) {
  const targets = kindCut(moonCut(synchronicTargets(natal, { bodies: spec.bodies, aspects: spec.aspects }), ['ingress', 'flip']), spec.kinds);
  return run(targets, spec, { probe: spec.probe, natal, natalOrb: spec.natalOrb, flipOrb: spec.flipOrb });
}
// Retrograde periods, bounded by the station roots the floor already found. Nothing rescans.
function retroPeriods(floorEvents) {
  const by = {}, out = [];
  for (const e of floorEvents) if (e.kind === 'station') (by[e.body] = by[e.body] || []).push(e);
  for (const b in by) {
    const st = by[b];
    for (let i = 0; i < st.length - 1; i++) {
      if (st[i].dir === 'retrograde' && st[i + 1].dir === 'direct') {
        out.push({ layer: 'floor', kind: 'retrograde', body: b, jd: st[i].jd, enter: st[i].jd,
          hinge: (st[i].jd + st[i + 1].jd) / 2, exit: st[i + 1].jd, days: st[i + 1].jd - st[i].jd,
          from: sideOf(st[i].lon, null), to: sideOf(st[i + 1].lon, null) });
      }
    }
  }
  return out.sort((a, b) => a.jd - b.jd);
}

function loomBuild(layer, natal, spec) {
  if (layer === 'floor') { const ev = buildFloor(spec); return ev.concat(retroPeriods(ev)).sort((a, b) => a.jd - b.jd); }
  if (layer === 'contact') return buildContact(natal, spec);
  if (layer === 'synchronic') return buildSynchronic(natal, spec);
  throw new Error('unknown loom layer: ' + layer);
}

window.__ORBO_LOOM = { STEP_FOR, stepFor, CONFIRM, CONFIRM_SPEED, scanTargets, decorate, buildFloor, buildContact, buildSynchronic, retroPeriods, loomBuild };
})();
