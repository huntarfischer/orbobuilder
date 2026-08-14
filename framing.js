// framing.js — composite framing methodology engine
import { norm360, wrap180, julianDay, jdToDate, positions, angles, findAscAnchor, BODY_ORDER } from './ephem.js';
// The Ring is the floor and imports nothing, so depending on it adds no cycle. Angles only:
// it holds no signs, no rulers and no orb, so the DEGREE relation comes from here.
import { MARKS, separation, arcOf } from './ring.js';
// The Mater is the Ring's sibling and imports nothing either: the inherent MEANING of the twelve
// signs. Names, glyphs, elements, traditional rulership, the house frames, exaltation and the
// derived detriment/fall tables all live there now, stamped once. This file used to carry its own
// copies of the sign names, the glyphs, the rulers, the exaltations and the house rotation.
import { SIGNS, SIGN_GLYPHS, RULERS, dignityOfSign } from './mater.js';
// The twelve whole-sign frames are the TYMPAN's, not the Mater's (the Connectome pass moved them).
import { houseOfSign } from './tympan.js';

export { SIGNS, SIGN_GLYPHS, RULERS };
export const GLYPHS = { Sun:'☉', Moon:'☽', Mercury:'☿', Venus:'♀', Mars:'♂', Jupiter:'♃', Saturn:'♄', Uranus:'♅', Neptune:'♆', Pluto:'♇', Node:'☊', SNode:'☋', Chiron:'⚷', Lilith:'⚸', Asc:'AC', Mc:'MC', Fortune:'⊗', Spirit:'Spi', Eros:'Ero', Necessity:'Nec', Courage:'Cou', Victory:'Vic', Nemesis:'Nem' };

// ---------- Hermetic lots (Arabic parts) ----------
// Day/night formulas per the classical Hermetic set; asc in degrees, pos = positions map.
export const LOTS = ['Fortune','Spirit','Eros','Necessity','Courage','Victory','Nemesis'];
export const LOT_SHORT = { Fortune:'For', Spirit:'Spi', Eros:'Ero', Necessity:'Nec', Courage:'Cou', Victory:'Vic', Nemesis:'Nem' };
export function lots(asc, isDay, pos) {
  const L = {};
  const part = (a, b) => norm360(asc + (isDay ? a - b : b - a));
  L.Fortune   = part(pos.Moon, pos.Sun);
  L.Spirit    = part(pos.Sun, pos.Moon);
  L.Eros      = part(pos.Venus, L.Spirit);
  L.Necessity = part(L.Fortune, pos.Mercury);
  L.Courage   = part(L.Fortune, pos.Mars);
  L.Victory   = part(pos.Jupiter, L.Spirit);
  L.Nemesis   = part(L.Fortune, pos.Saturn);
  return L;
}
export const BODIES = BODY_ORDER;
export { norm360, wrap180, julianDay, jdToDate, positions, angles, findAscAnchor };

export function signIndex(lon) { return Math.floor(norm360(lon) / 30) % 12; }
export function degInSign(lon) { return norm360(lon) % 30; }
export function fmtLon(lon) {
  const d = Math.floor(degInSign(lon)); const m = Math.round((degInSign(lon) - d) * 60);
  const dd = m === 60 ? d + 1 : d, mm = m === 60 ? 0 : m;
  return `${dd}°${String(mm).padStart(2,'0')}′ ${SIGNS[signIndex(lon)].slice(0,3)}`;
}
export function midpoint(a, b) { return norm360(a + wrap180(b - a) / 2); }

// ---------- the refraction door (Phase 6 · P1) ----------
// THE ONE PLACE IN ORBO THAT REFRACTS. The prism is inserted at exactly one seam: if two places
// refract they will disagree, so this is a door in the sense spine.at is a door, and it is meant to
// be greppable. A refracted position is midpoint(natal, moment) — nothing more, and deliberately no
// table (§3: the refraction is one wrap and one halving, and a 360-row table would quantize to whole
// degrees against the codec law). Null-tolerant because a caller may hold a body the genome lacks.
//
// It COMMUTES with lot formation, which is why the lots need no second definition here: a lot is an
// affine combination whose coefficients sum to 1 (asc + moon − sun, 1 + 1 − 1 = 1), so refracting
// Fortune and computing Fortune from the refracted Ascendant, Moon and Sun give the same degree
// (§13.4). The one thing that breaks the commutation is a SECT disagreement between the natal and
// the synchronic chart, which is why P1 refracts the lots LIVE and stores no lot arc.
export function refract(natalLon, momentLon) {
  if (natalLon == null || momentLon == null) return null;
  return midpoint(natalLon, momentLon);
}
// Whole-sign, anchored to the ASC sign: a LOOKUP into the Mater's stamped frame. The sign index is
// arithmetic and stays local; the frame is a table and is never copied.
export function houseOf(lon, ascLon) { return houseOfSign(signIndex(lon), signIndex(ascLon)); }

// ---------- natal ----------
export function computeNatal(p) {
  const jd = julianDay(p.y, p.mo, p.d, p.h, p.mi, 0, p.tz);
  const pos = positions(jd);
  const ang = angles(jd, p.lat, p.lon);
  const sunAboveHorizon = norm360(pos.Sun - ang.asc) >= 180;
  return { ...p, jd, pos, asc: ang.asc, mc: ang.mc, isDay: sunAboveHorizon, sectLight: sunAboveHorizon ? 'Sun' : 'Moon', ascRuler: RULERS[signIndex(ang.asc)] };
}

// ---------- frames ----------
// A frame for calendar day D (local midnight jd0): anchor = when natal ASC degree rises at birth location.
export function frameFor(natal, jdLocalMidnightUT) {
  const anchorJd = findAscAnchor(jdLocalMidnightUT, natal.asc, natal.lat, natal.lon);
  if (anchorJd == null) return null;
  const moment = positions(anchorJd);
  const comp = {};
  for (const b of BODIES) comp[b] = midpoint(natal.pos[b], moment[b]);
  // anchored at natal ASC rising → moment angles == natal angles → composite angles == natal angles
  return { anchorJd, moment, comp, asc: natal.asc, mc: natal.mc };
}

// ---------- the axial triple (Stage A, 2026-07-29) ----------
// LAW: the axis is STORAGE, never a second placement. The transcript retracted the
// counter-dispositor: the two ends of the arc are the limits of the object's permitted
// movement, not two co-present placements. One dispositor at a time, always the displayed
// point's. Never build a counter-dispositor field off axisOf().
//
// The white paper's phase formula (φ = ⌊(T̃−N)/360⌋ mod 2, needing an unwrapped trace from
// birth) is WRONG — see CLAUDE.md · Synchronic doctrine for the derivation. The synchronic
// placement of body P never leaves the 180° arc centred on natal P, so parity falls straight
// out of WRAPPED longitudes and needs no trace and no unwrapping.
export function phaseOf(natalLon, transLon) { return norm360(transLon - natalLon) >= 180 ? 1 : 0; }
// the mod-180 coordinate: what is stored. Both ends of the permitted arc are axis and axis+180.
export function axisOf(natalLon, transLon) { return norm360(midpoint(natalLon, transLon)) % 180; }
// the whole triple, as it rides on the genome: displayed point, axis, phase, permitted arc.
export function axialOf(natalLon, transLon) {
  const point = midpoint(natalLon, transLon);
  return { point, axis: norm360(point) % 180, phase: phaseOf(natalLon, transLon), arc: arcFor(natalLon) };
}

// ---------- synchronic orbs (Stage C.6) ----------
// Separations HALVE on this layer, so natal orb defaults read nearly everything as a contact.
// Base is half the natal orb, tapered by aspect strength. The ♍ Orb socket remains the override.
export const SYN_ORB_FACTOR = { 0: 1, 180: 1, 120: 0.84, 90: 0.84, 60: 0.67, 45: 0.34, 135: 0.34, 30: 0.34, 150: 0.34, 72: 0.34, 144: 0.34 };
export function synOrb(angle, natalOrb = 6) { return (natalOrb / 2) * (SYN_ORB_FACTOR[angle] ?? 0.34); }

// ---------- arcs ----------
export function arcFor(natalLon) { return { center: norm360(natalLon), start: norm360(natalLon - 90), end: norm360(natalLon + 90) }; }
export function inArc(lon, arc) { return Math.abs(wrap180(lon - arc.center)) <= 90.0001; }
// overlap of two 180° arcs → array of [start,end] segments (0–2)
export function arcOverlap(a1, a2) {
  const d = Math.abs(wrap180(a1.center - a2.center));
  if (d >= 180 - 1e-9) return [];
  // overlap on each side
  const segs = [];
  // arcs as centered intervals; overlap = intersection on circle
  const s = norm360(Math.abs(wrap180(a2.start - a1.center)) <= 90 ? a2.start : a1.start);
  // simpler: overlap length = 180 - d, centered at midpoint of the two centers
  const len = 180 - d;
  const mid = midpoint(a1.center, a2.center);
  segs.push({ start: norm360(mid - len / 2), end: norm360(mid + len / 2), len });
  return segs;
}
export function overlapLen(a1, a2) { const d = Math.abs(wrap180(a1.center - a2.center)); return Math.max(0, 180 - d); }

// ---------- scans ----------
export function scanFrames(natal, jdStart, days, cache) {
  const frames = [];
  for (let i = 0; i < days; i++) {
    const key = `${natal.jd.toFixed(5)}|${(jdStart + i).toFixed(3)}`;
    let fr = cache && cache.get(key);
    if (!fr) { fr = frameFor(natal, jdStart + i); if (cache) cache.set(key, fr); }
    frames.push(fr);
  }
  return frames;
}
// events: sign ingresses per body. Flips are NO LONGER detected here — the old `d > 150`
// frame-to-frame jump heuristic was a fake, and its dates were quantised to the day grid.
// A flip is a parity change, exact at transiting P opposite natal P: see flipEvents().
export function frameEvents(natal, frames, jdStart) {
  const ev = [];
  for (let i = 1; i < frames.length; i++) {
    const a = frames[i - 1], b = frames[i];
    if (!a || !b) continue;
    for (const body of BODIES) {
      const s1 = signIndex(a.comp[body]), s2 = signIndex(b.comp[body]);
      if (Math.abs(wrap180(b.comp[body] - a.comp[body])) > 150) continue; // parity change, not an ingress
      if (s1 !== s2) {
        ev.push({ jd: jdStart + i, body, type: 'ingress', from: s1, to: s2, lon: b.comp[body], retro: wrap180(b.comp[body] - a.comp[body]) < 0 });
      }
    }
  }
  return ev;
}

// ---------- flips as first-class events (Stage B, 2026-07-29) ----------
// A flip is transiting P opposing natal P, and nothing else. It is an ordinary natal transit
// aspect, so it is cheap: detect the parity change on a coarse grid, bisect the exact hinge.
//
// It is a WINDOW, not an instant: approach \u00b7 hinge \u00b7 departure. At the hinge neither pole has a
// privileged claim. Retrograde stutter is honoured as THREE EVENTS (ruled 2026-07-29), never one
// event with three exacts and never smoothed \u2014 each carries its own window, so the windows
// overlap through the station and that smear is the signature.
//
// A flip is a REFORMULATION, not a new subject: the concern reached the end of one phase and is
// being lived from a newly oriented position. Sign, house and dispositor invert together, so the
// record carries all three on both sides.
export const FLIP_BODIES = BODIES.filter((b) => b !== 'SNode');
// NO body is excluded from the flip scan (corrected 2026-07-29, second pass). An earlier version of
// this file excluded Pluto and Lilith. Both exclusions were wrong:
//   Pluto  — the "~124 year half-cycle" that justified dropping it is the MEAN, and Pluto's orbit is
//            far too eccentric for a mean to decide this. It crosses Scorpio in about twelve years
//            and Taurus in about thirty-two, so the half-cycle FROM A GIVEN NATAL POSITION varies
//            enormously. A native with Pluto in Leo reaches transiting Pluto opposite natal Pluto in
//            Aquarius in their late seventies, which is to say the whole boomer generation is at its
//            Pluto flip right now. That is not an event to compute away; for a native with Pluto as
//            modern chart ruler it is arguably the single most consequential flip a life contains.
//   Lilith — the osculating apogee's several-degree, ~6 month oscillation does make its opposition
//            crossable many times over (measured at 15 in seven months). But that is the SAME
//            phenomenon as retrograde stutter, which doctrine says to honour rather than smooth, and
//            Lilith is not decoration to the natives who read it. It stays in.
// Which bodies are in play is the reader's choice (♊ Bodies), passed in as opts.bodies. The engine
// does not decide for the native which of their own placements are worth an event.

// synchronic speed is ephemeris speed HALVED (never differenced from consecutive frames)
export function synSpeed(bodySpeed) { return bodySpeed / 2; }

// The displayed point jumps 180° AT the hinge (that is what a flip is), so from/to are read a
// hair either side of it rather than at it, where the value is undefined.
function flipRecord(natal, body, hingeJd, toPhase, windowDays, fromLon, toLon) {
  const ascSign = signIndex(natal.asc);
  const side = (lon) => {
    const sg = signIndex(lon), disp = RULERS[sg];
    return { lon: norm360(lon), sign: sg, signName: SIGNS[sg], house: ((sg - ascSign) + 12) % 12 + 1, dispositor: disp };
  };
  return {
    type: 'flip', body, jd: hingeJd, phase: toPhase,
    axis: norm360(toLon) % 180, arc: arcFor(natal.pos[body]),
    enter: hingeJd - windowDays, hinge: hingeJd, exit: hingeJd + windowDays,
    from: side(fromLon), to: side(toLon),
  };
}

// posAt(jd) -> positions map (bodies only). speedAt(jd, body) optional -> deg/day.
export function flipEvents(natal, jdStart, jdEnd, posAt, opts = {}) {
  const step = opts.step || 0.5;                 // Moon moves ~13\u00b0/day; stations are slower still
  const orb = opts.flipOrb != null ? opts.flipOrb : 1; // window half-width, in degrees of separation
  const bodies = (opts.bodies || FLIP_BODIES).filter((b) => natal.pos[b] != null);
  const jdTo = Math.min(jdEnd, jdStart + (opts.maxSpan || 3700)); // ~10 years per call; the scan is O(span/step)
  const out = [];
  // signed distance from the opposition, continuous across the hinge (no abs kink)
  const gap = (jd, body) => wrap180(norm360(posAt(jd)[body] - natal.pos[body]) - 180);
  for (const body of bodies) {
    if (natal.pos[body] == null) continue;    let pj = jdStart, pv = gap(jdStart, body);
    for (let jd = jdStart + step; jd <= jdTo; jd += step) {
      const cv = gap(jd, body);
      if (Math.abs(cv - pv) > 90) { pj = jd; pv = cv; continue; } // wrapped the far side, not a hinge
      if (pv !== 0 && Math.sign(cv) === Math.sign(pv)) { pj = jd; pv = cv; continue; }
      let lo = pj, hi = jd;
      for (let i = 0; i < 42; i++) { const mid = (lo + hi) / 2; if (Math.sign(gap(mid, body)) === Math.sign(pv)) lo = mid; else hi = mid; }
      const hinge = (lo + hi) / 2;
      // window: how long the separation stays within `orb` of exact, from local synchronic speed
      const h = 0.02, v = Math.abs(gap(hinge + h, body) - gap(hinge - h, body)) / (2 * h);
      const win = v > 1e-6 ? Math.min(45, orb / v) : step;
      const eps = Math.max(1e-4, win / 40), nl = natal.pos[body];
      const toPhase = phaseOf(nl, posAt(hinge + eps)[body]);
      out.push(flipRecord(natal, body, hinge, toPhase, win,
        midpoint(nl, posAt(hinge - eps)[body]), midpoint(nl, posAt(hinge + eps)[body])));
      pj = jd; pv = cv;
    }
  }
  return out.sort((a, b) => a.jd - b.jd);
}

// ---------- the synchronic event engine (Stage B.2, 2026-07-29; rewired 7b, 2026-08-04) ----------
// A flip is one KIND of synchronic event, and on its own it is a thin reading. Three kinds, all of
// them events in the native's own synchronic chart:
//
//   'flip'     a placement reaches the end of its permitted arc and is lived from the opposite pole.
//              Sign, house and dispositor invert together. A change of government BY INVERSION, which
//              is why it keeps its own name: it is not an opposition, whatever its root is.
//   'ingress'  a placement crosses a sign boundary. Because houses are natal whole-sign anchored to
//              the natal ASC, A SIGN BOUNDARY *IS* A HOUSE BOUNDARY \u2014 one crossing carries both
//              readings at once: a new manner (sign) and a new arena (house). It also hands the
//              placement to a new dispositor, so like a flip it is a change of governor, but by
//              ordinary motion rather than by inversion.
//   'aspect'   synastry between two fields: two synchronic placements come to exact contact. Both
//              move (each at half its own transiting speed), so unlike the same-body bead families
//              these genuinely FORM, perfect and separate. THE RING DECREES THE ASPECT AT EXACT.
export const SYN_KINDS = ['flip', 'ingress', 'aspect'];

// THE FALLBACK, AND IT IS NOT A SECOND SCANNER (step 7b, 2026-08-04). The DC reads the fertilized
// weave first and reaches this door whenever the table cannot answer: not built, a different chart,
// or a window past the edge of the fertilized span. That path is live for every reader who has not
// finished fertilizing, which is every new reader, so the door stays exactly where it is \u2014 deleting
// it would take \u2650 Field dark for all of them.
//
// What it LOST is its own scanning body. There is ONE scanner (loom.js) and this delegates to it, so
// the phase gate, the cusp-hover guard, the bisection and the three-kind grid walk that used to live
// here are gone rather than maintained twice. loom imports this file, so the scanner arrives
// INJECTED (opts.loom) rather than imported: no cycle, and with none in hand the field goes dark
// while the plate never does (the instrument-survives-everything law). Signature and return shape are
// unchanged, so every \u2650 Field reader is untouched.
export function synEvents(natal, jdStart, jdEnd, posAt, opts = {}) {
  const L = opts.loom;
  if (!L || !L.loomBuild || !natal || !natal.pos) return [];
  const jdTo = Math.min(jdEnd, jdStart + (opts.maxSpan || 3700));
  const rows = L.loomBuild('synchronic', natal, {
    jdStart, jdEnd: jdTo, probe: posAt, step: opts.step,
    kinds: opts.kinds || SYN_KINDS,
    bodies: opts.bodies, aspects: opts.aspects || [0, 90, 180],
    natalOrb: opts.orb != null ? opts.orb : 6,
    flipOrb: opts.flipOrb != null ? opts.flipOrb : 1,
  });
  return synShape(rows);
}

// ONE translator from the loom's record shape into the shape \u2650 Field reads, and it used to be
// written twice: once at the bottom of the old synEvents and once in the DC's read of the fertilized
// weave. Both sources agree on kind/body/from/to/angle/aSide/bSide, so both come through here.
export function synShape(rows) {
  const out = (rows || []).map((r) => {
    const axis = r.axis != null ? r.axis : (r.to && r.to.lon != null ? mod180(r.to.lon) : undefined);
    if (r.kind === 'flip') {
      return { type: 'flip', jd: r.jd, body: r.body, phase: r.phase, axis,
        enter: r.enter, hinge: r.hinge != null ? r.hinge : r.jd, exit: r.exit,
        from: r.from, to: r.to, governed: r.governed };
    }
    if (r.kind === 'ingress') {
      return { type: 'ingress', jd: r.jd, body: r.body, retro: r.retro, axis,
        from: r.from, to: r.to, lon: r.to ? r.to.lon : undefined,
        boundary: r.boundary, governed: r.governed };
    }
    // The word is the Ring's word for the mark the placements actually reached, never a reading word
    // standing in for one: 'contact' names a conjunction in this instrument and must not label a
    // sextile. A glyph the admitted five do not carry reads as no glyph rather than as a wrong one.
    const ang = Math.abs(r.angle);
    const asp = ASPECTS.find((x) => x.angle === ang);
    return { type: 'aspect', jd: r.jd, a: r.body, b: r.other, angle: ang,
      name: asp ? asp.name : r.name, glyph: asp ? asp.glyph : '',
      enter: r.enter, hinge: r.hinge != null ? r.hinge : r.jd, exit: r.exit,
      aSide: r.aSide, bSide: r.bSide };
  });
  return out.sort((a, b) => a.jd - b.jd);
}

// ---------- same-body bead families (Stage C.1\u20133) ----------
// Two synchronic composites of the SAME body have a separation fixed at half the natal
// separation, forever. The family is {\u03b4/2, 180\u2212\u03b4/2} and only the MODE alternates, selected by
// \u03c6_A \u2295 \u03c6_B. Nothing here is scanned; it is closed-form and time-invariant, which is exactly
// why same-body and cross-body contacts must not share one list.
export function beadFamily(natalLonA, natalLonB) {
  const sep = Math.abs(wrap180(natalLonA - natalLonB));
  const modes = [sep / 2, 180 - sep / 2];
  // the square is self-complementary ({90,90}): a flip changes which side, not the class, so
  // announcing a mode change there would be a lie. Suppress the mode display.
  return { sep, modes, selfComplementary: Math.abs(modes[0] - modes[1]) < 1e-6 };
}
export function beadMode(fam, phaseA, phaseB) {
  const i = (phaseA ^ phaseB) ? 1 : 0;
  return { index: i, separation: fam.modes[i], other: fam.modes[i ^ 1], suppressed: fam.selfComplementary };
}
// first-order mode durations, free and exact enough to show before any refinement: two natal
// positions \u03b4 apart split the transiting body's cycle into \u03b4/360 and (360\u2212\u03b4)/360 of it.
export function beadModeDays(fam, periodDays) {
  const d = fam.sep;
  return [periodDays * d / 360, periodDays * (360 - d) / 360];
}

// ---------- S0 · the target algebra (Phase 5 · The Loom, 2026-07-29; rewired 7b 2026-08-04) --------
// Two threads, two weaves. THREAD sky (the mundane floor, native-independent and place-free) and
// THREAD native (the engraved chart). They weave by CONTACT (a transiting body touches a natal
// degree: the sky meeting you, still two things) and SYNCHRONICALLY (the two become one placement at
// the midpoint: the sky merged with you).
//
// THE WORD IS SYNCHRONIC. An earlier pass called this layer "union", a word invented here for a layer
// that already had a name, while synOrb, synEvents and synKinds all spoke correctly beside it. The
// instrument says synchronic everywhere it means synchronic. midpoint() is untouched: THE MIDPOINT IS
// PRIMARY, it is the display derivation, and this layer is never described as the transiting layer
// "halved".
//
// EVERYTHING IN ORBO EXISTS ON THE RING. There is no synchronic space, so there is nothing to pull
// back FROM, and the entire coordinate resolution that used to live here is gone: unionToSky,
// skyToUnion, unionIngressTargets, unionFlipTarget, unionSepToSky, unionSep, unionAxisSep,
// unionSepFamily, unionSepClass, the supplement dedup loop and the `serves` list. They existed only
// because sky-space questions were being asked about a Ring occupant. A synchronic Mars at 0 Aries IS
// at 0 Aries. `layer` is not a geometry, it is WHICH OCCUPANT IS SITTING THERE, and the only genuine
// difference between the layers is SPEED (natal 0, transiting v, synchronic v/2), which is time and
// belongs to the scanner.
//
// SO A TARGET'S DEGREE IS A DEGREE OF ITS OWN OCCUPANT, and the field is named `deg`, never `sky`. An
// occupant is a body, optionally measured from a natal degree: `nat` absent is the sky itself (the
// floor and the contact weave), `nat` present is the synchronic placement midpoint(nat, sky). That
// one composition is the whole of what the scanner learns about this layer, and it is a restatement
// of the line above rather than an addition to it.
//
// WHAT THE DELETION COST, MEASURED BEFORE A LINE WAS WRITTEN (the fixture natal, a 400 day window:
// 128 ingresses, 19 flips, 147 contacts, every root paired with the pullback's at max delta 0.00
// minutes, and ring.nearest exact on all 147):
//   THE PHASE GATE IS NOT REPLACED, IT IS UNNECESSARY. The displayed point jumps 180 degrees at a
//   flip, so it reaches the scanner as an ordinary WRAP, and the scanner has carried a generic wrap
//   guard for every layer since S1. The `d > 150` heuristic and its successor parity gate are not
//   superseded by a cleverer coordinate; they are superseded by the observation that a pole jump is a
//   wrap and one scanner already handles wraps. Do not reintroduce a parity bit to "help" it.
//   THE RESIDENCY GUARD STAYS, at v0.878's 0.1 degrees, expressed in the occupant's own degrees,
//   which is the coordinate it was originally written in.
//   SUPPLEMENT CLOSURE IS STILL A FACT OF THE SET (0/180, 30/150, 45/135, 60/120 pair and 90 pairs
//   with itself; 72 and 144 do not). What died is the LIST that conflated a root with its
//   supplement's label. Every admitted angle is now its own target in its own direction, so no root
//   is shared, nothing is deduped, and nothing needs relabelling after the fact. Direct scanning
//   loses no root as long as the admitted set is closed under supplement, which the five majors are.
//   RETROGRADE FLIP STUTTER IS STILL THREE EVENTS. A cleaner scanner must not smooth it.
//
// Everything here is PURE. No scanning, no ephemeris, no probe. A target says WHERE a root lies in
// its occupant's own space; the one scanner in loom.js finds it. Three layers, one scanner, three
// target sets: do not write a synchronic spine, write the third target set.
//
// Target record, common to all three:
//   { layer, kind, mode, body, other, nat, natOther, angle, deg, ...labels }
//   mode 'lon'   solve the occupant's longitude == `deg`
//   mode 'sep'   solve wrap180(occupant[body] - occupant[other]) == `deg`
//   mode 'speed' solve d(sky longitude of `body`)/dt == 0   (stations; shared by all three layers,
//                because a synchronic placement is stationary exactly when its sky body is)
export const LOOM_LAYERS = ['floor', 'contact', 'synchronic'];
export const SIGN_BOUNDARIES = [0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330];
// The axis: mod-180 STORAGE, never a second placement. The transcript retracted the
// counter-dispositor, so the two ends of the arc are the limits of permitted movement and one
// dispositor is live at a time.
export function mod180(x) { const v = norm360(x) % 180; return v; }
// Residency confirmation for a synchronic root, in the occupant's OWN degrees (v0.878's figure). A
// flip's root is a sky-space root BY NATURE, since a flip is transiting P opposing natal P and
// nothing else, so it carries the same law expressed in sky degrees, which is twice this. Never
// relax either into a smoothing of genuine retrograde stutter: a real stutter moves the placement
// whole degrees over weeks, where the v0.878 Node sat within 0.02 degrees of 0 Aries and wobbled.
export const SYN_CONFIRM = 0.1;

// --- the three target sets ---
const NO_MIRROR = (b) => b !== 'SNode';   // any aspect to SNode mirrors one to Node, 180 away
export function floorTargets(opts = {}) {
  const bodies = (opts.bodies || BODIES).filter(NO_MIRROR);
  const angles = opts.aspects || [0, 60, 90, 120, 180];
  const out = [];
  for (const b of bodies) {
    for (let k = 0; k < 12; k++) out.push({ layer: 'floor', kind: 'ingress', mode: 'lon', body: b, deg: SIGN_BOUNDARIES[k], sign: k });
    if (b !== 'Sun' && b !== 'Node') out.push({ layer: 'floor', kind: 'station', mode: 'speed', body: b, deg: 0 });
  }
  for (let i = 0; i < bodies.length; i++) for (let j = i + 1; j < bodies.length; j++) {
    const a1 = bodies[i], a2 = bodies[j];
    const syz = (a1 === 'Sun' && a2 === 'Moon') || (a1 === 'Moon' && a2 === 'Sun');
    for (const ang of angles) for (const s of (ang === 0 || ang === 180 ? [ang] : [ang, -ang])) {
      const kind = syz && (ang === 0 || ang === 180 || ang === 90) ? 'syzygy' : 'aspect';
      out.push({ layer: 'floor', kind, mode: 'sep', body: a1, other: a2, angle: ang, deg: s });
    }
  }
  return out;
}
// contact: natal-relative. N + A, both directions. The occupant is the sky body itself, so no target
// here carries `nat`. A flip lives here too, as a body against itself at 180, which is why the
// synchronic weave never rescans one.
export function contactTargets(natal, opts = {}) {
  const transiting = (opts.bodies || BODIES).filter(NO_MIRROR);
  const angles = opts.aspects || [0, 60, 90, 120, 180];
  const pts = {};
  for (const b of BODIES) if (natal.pos[b] != null) pts[b] = natal.pos[b];
  if (opts.angles !== false) { pts.Asc = natal.asc; pts.Mc = natal.mc; }
  const out = [];
  for (const t of transiting) for (const g in pts) for (const ang of angles) {
    for (const s of (ang === 0 || ang === 180 ? [ang] : [ang, -ang])) {
      out.push({ layer: 'contact', kind: t === g && ang === 180 ? 'flip' : 'aspect', mode: 'lon',
        body: t, other: g, angle: ang, deg: norm360(pts[g] + s) });
    }
  }
  return out;
}
// synchronic: the occupant IS midpoint(natal, sky), and every target is a degree of that placement.
// Nothing is resolved into sky space, so the scanner never knows the difference and neither does this.
export function synchronicTargets(natal, opts = {}) {
  const bodies = (opts.bodies || BODIES).filter((b) => NO_MIRROR(b) && natal.pos[b] != null);
  const angles = opts.aspects || [0, 60, 90, 120, 180];
  const out = [];
  for (const b of bodies) {
    const nl = natal.pos[b];
    // INGRESS \u00b7 TWELVE whole-sign houses, six of them ever reachable by this placement, forever. The
    // permitted arc is 180 degrees wide, so it touches seven signs and contains SIX boundaries (seven
    // when the natal degree is itself a boundary, where both ends of the arc land on one). Under the
    // natal whole-sign law a sign boundary IS a house boundary, so one crossing carries a new manner
    // and a new arena at once and hands the placement to a new dispositor.
    for (let k = 0; k < 12; k++) {
      const bd = SIGN_BOUNDARIES[k];
      if (Math.abs(wrap180(bd - nl)) > 90 + 1e-9) continue;   // outside the arc: never crossed, ever
      out.push({ layer: 'synchronic', kind: 'ingress', mode: 'lon', body: b, nat: nl, deg: bd, sign: k,
        hinge: Math.abs(Math.abs(wrap180(bd - nl)) - 90) < 1e-9, confirm: SYN_CONFIRM });
    }
    // FLIP \u00b7 transiting P opposing natal P, and nothing else, which is the contact weave's own 180
    // root on the same body. The occupant here is therefore the SKY body (no `nat`), and the flip
    // keeps its own name because of what it MEANS: a change of government by inversion is not an
    // opposition, and sign, house and dispositor invert together.
    out.push({ layer: 'synchronic', kind: 'flip', mode: 'lon', body: b, deg: norm360(nl + 180),
      angle: 180, confirm: SYN_CONFIRM * 2 });
  }
  // ASPECT \u00b7 synastry between two fields. Both placements move, each at half its own sky rate, so
  // unlike the same-body bead families (closed form, time-invariant, parity-selected) these genuinely
  // FORM, perfect and separate. Every admitted angle is its own target in its own direction.
  for (let i = 0; i < bodies.length; i++) for (let j = i + 1; j < bodies.length; j++) {
    const b1 = bodies[i], b2 = bodies[j];
    for (const ang of angles) for (const s of (ang === 0 || ang === 180 ? [ang] : [ang, -ang])) {
      out.push({ layer: 'synchronic', kind: 'aspect', mode: 'sep', body: b1, other: b2,
        nat: natal.pos[b1], natOther: natal.pos[b2], angle: ang, deg: s,
        natalSep: Math.abs(wrap180(natal.pos[b1] - natal.pos[b2])), confirm: SYN_CONFIRM });
    }
  }
  return out;
}
export function loomTargets(layer, natal, opts) {
  if (layer === 'floor') return floorTargets(opts);
  if (layer === 'contact') return contactTargets(natal, opts);
  if (layer === 'synchronic') return synchronicTargets(natal, opts);
  throw new Error('unknown loom layer: ' + layer);
}

// ---------- dispositor chain ----------
export function dispositorChain(startBody, compPos) {
  const chain = [{ body: startBody, sign: signIndex(compPos[startBody]) }];
  const seen = new Set([startBody]);
  let cur = startBody;
  for (let i = 0; i < 8; i++) {
    const ruler = RULERS[signIndex(compPos[cur])];
    if (seen.has(ruler)) { chain.push({ body: ruler, sign: signIndex(compPos[ruler]), terminal: true }); break; }
    seen.add(ruler);
    chain.push({ body: ruler, sign: signIndex(compPos[ruler]) });
    cur = ruler;
  }
  return chain;
}

// ---------- synastry scoring ----------
// THE FIVE MAJORS, ADMITTED FROM THE RING (rewire step A, 2026-08-03). The words and glyphs are
// unchanged and stay here for now; they are MEANING and belong in the mater once it exists (rewire
// step D2). What moved is the KEY SET. This table deliberately carries five of the Ring's eleven
// marks, so the narrowing is DECLARED and CHECKED rather than left as a coincidence: a member of
// ADMITS that is not a mark, or a mark with no decoration, throws AT LOAD rather than yielding an
// undefined name at the one moment a reader is reading.
// Marks deliberately NOT carried here: 30 · 45 · 72 · 135 · 144 · 150. Widening this list is a
// doctrine change, not a tidy-up. Verified zero-delta in tests/rewire-parity.test.html.
const ASPECT_ADMITS = [0, 60, 90, 120, 180];
const ASPECT_WORD = { 0: 'conjunction', 60: 'sextile', 90: 'square', 120: 'trine', 180: 'opposition' };
const ASPECT_GLYPH = { 0: '☌', 60: '✶', 90: '□', 120: '△', 180: '☍' };
export const ASPECTS = Object.freeze(ASPECT_ADMITS.map((angle) => {
  if (!MARKS.includes(angle)) throw new Error('framing: ' + angle + ' is not a Ring mark');
  const name = ASPECT_WORD[angle], glyph = ASPECT_GLYPH[angle];
  if (!name || !glyph) throw new Error('framing: no decoration for admitted mark ' + angle);
  return Object.freeze({ angle, name, glyph });
}));
// Min-residual over the ADMITTED set, not over all eleven: ring.nearest() would answer for marks
// this reader does not carry. The arc is the Ring's (arcOf(separation)) rather than a local
// abs(wrap180) — same value to 8.3e-14 over 49,623 pairs, one owner instead of two.
export function aspectBetween(a, b, orbMax) {
  const d = arcOf(separation(a, b));
  let best = null;
  for (const asp of ASPECTS) {
    const orb = Math.abs(d - asp.angle);
    if (orb <= orbMax && (!best || orb < best.orb)) best = { ...asp, orb };
  }
  return best;
}
// ---------- dignity ----------
// The ladder and the four tables it walks are the Mater's, and its vocabulary is already this
// file's: domicile · exaltation · detriment · fall · null. Detriment and fall are read off tables
// derived at stamp time, so the opposition is no longer run per call.
export const dignityOf = (body, sign) => dignityOfSign(body, sign);

// ---------- electional scoring (per user interview, July 2026) ----------
const Q = { 0: 0.7, 60: 0.8, 90: -0.9, 120: 1.0, 180: -0.7 };
export const PROFILES = {
  text:     { label: 'Send a text', desc: 'Mercury-led; quick, light, well-received.', sigs: ['Mercury'], holders: ['Mercury'], houses: [3], initiating: true },
  date:     { label: 'Go on a date', desc: 'Venus warmth, lunar ease.', sigs: ['Venus'], holders: ['Venus', 'Jupiter'], houses: [5], initiating: true },
  hard:     { label: 'Hard conversation', desc: 'Saturn-held field; low volatility.', sigs: ['Mercury', 'Saturn'], holders: ['Saturn'], houses: [8] },
  ask:      { label: 'Ask for something', desc: 'Jupiter-carried request; open hands.', sigs: ['Jupiter'], holders: ['Jupiter'], houses: [11], initiating: true },
  repair:   { label: 'Apologize / repair', desc: 'Venus grace with Saturn accountability.', sigs: ['Venus', 'Saturn'], holders: ['Venus', 'Saturn'], houses: [4] },
  intimacy: { label: 'Intimacy', desc: 'Venus–Mars charge, deep water.', sigs: ['Venus', 'Mars'], holders: ['Venus', 'Mars'], houses: [5, 8], initiating: true },
  business: { label: 'Business / negotiation', desc: 'Structured exchange; Saturn–Mercury–Jupiter.', sigs: ['Mercury', 'Saturn'], holders: ['Saturn', 'Mercury', 'Jupiter'], houses: [7] },
  silence:  { label: 'Silence', desc: 'Best days NOT to engage — field at rest.', sigs: ['Saturn'], holders: ['Saturn'], houses: [12], invert: true },
};

export function scoreDay(natA, frameA, natB, frameB, profileKey, orbMax, frameA2, frameB2) {
  const prof = PROFILES[profileKey];
  const hits = [];
  let aspectScore = 0, factorScore = 0;
  const G = GLYPHS;
  const isApplying = (l1, l2, l1n, l2n, angle, orbNow) =>
    Math.abs(Math.abs(wrap180(l1n - l2n)) - angle) < orbNow;
  // Profile-driven pair weights: cross-aspects not touching this activity's
  // significators/holders/sect lights contribute nothing (mirrors solo scorer).
  const sideWeight = (b, nat) => prof.sigs.includes(b) ? 1.6 : prof.holders.includes(b) ? 1.15 : b === nat.sectLight ? 0.6 : (b === 'Sun' || b === 'Moon') ? 0.35 : 0;
  const pairWeight = (b1, b2) => {
    if (prof.sigs.includes(b1) && prof.sigs.includes(b2)) return 2.5;
    return Math.max(sideWeight(b1, natA), sideWeight(b2, natB));
  };
  // planet-planet cross aspects — APPLYING ONLY
  // planet-planet cross aspects — APPLYING ONLY (SNode skipped: mirrors Node)
  for (const ba of BODIES) for (const bb of BODIES) {
    if (ba === 'SNode' || bb === 'SNode') continue;
    const w = pairWeight(ba, bb);
    if (!w) continue;
    const asp = aspectBetween(frameA.comp[ba], frameB.comp[bb], orbMax);
    if (!asp) continue;
    if (frameA2 && frameB2 && !isApplying(frameA.comp[ba], frameB.comp[bb], frameA2.comp[ba], frameB2.comp[bb], asp.angle, asp.orb)) continue;
    const val = w * Q[asp.angle] * (1 - asp.orb / orbMax);
    aspectScore += val;
    hits.push({ val, kind: 'aspect', a: ba, b: bb, angle: asp.angle, txt: `A ${G[ba]} ${ba} ${asp.glyph} B ${G[bb]} ${bb} · ${asp.orb.toFixed(1)}° applying` });
  }
  // aspects to composite angles (pinned to natal) — strongest contacts
  const angleSide = (fr, fr2, toNat, label) => {
    for (const b of BODIES) for (const [an, alon] of [['cASC', toNat.asc], ['cMC', toNat.mc]]) {
      if (b === 'SNode') continue;
      const w = sideWeight(b, label === 'A' ? natA : natB);
      if (!w) continue;
      const asp = aspectBetween(fr.comp[b], alon, orbMax);
      if (!asp) continue;
      if (fr2 && !isApplying(fr.comp[b], alon, fr2.comp[b], alon, asp.angle, asp.orb)) continue;
      const val = 1.5 * w * Q[asp.angle] * (1 - asp.orb / orbMax);
      aspectScore += val;
      hits.push({ val, kind: 'angle', txt: `${label} ${G[b]} ${b} ${asp.glyph} ${label === 'A' ? "B's" : "A's"} ${an} · ${asp.orb.toFixed(1)}° applying` });
    }
  };
  angleSide(frameA, frameA2, natB, 'A');
  angleSide(frameB, frameB2, natA, 'B');
  if (prof.invert) {
    aspectScore = -aspectScore * 0.6;
    hits.forEach(h => { if (h.kind === 'aspect' || h.kind === 'angle') h.val = -h.val * 0.6; });
  }
  // per-person factors
  for (const [nat, fr, fr2, otherFr, otherFr2, tag] of [[natA, frameA, frameA2, frameB, frameB2, 'A'], [natB, frameB, frameB2, frameA, frameA2, 'B']]) {
    // keeper of the light (sect-light dispositor) affinity
    const keeper = RULERS[signIndex(fr.comp[nat.sectLight])];
    if (prof.holders.includes(keeper)) { factorScore += 1.0; hits.push({ val: 1.0, kind: 'keeper', txt: `${tag}: Keeper ${G[keeper]} ${keeper} favors this work` }); }
    // dignity of sect light + significators (composite sign)
    for (const b of [...new Set([nat.sectLight, ...prof.sigs])]) {
      const d = dignityOf(b, signIndex(fr.comp[b]));
      if (d === 'domicile' || d === 'exaltation') { factorScore += 0.5; hits.push({ val: 0.5, kind: 'dignity', txt: `${tag}: ${G[b]} ${b} in ${d}` }); }
      else if (d) { factorScore -= 0.5; hits.push({ val: -0.5, kind: 'dignity', txt: `${tag}: ${G[b]} ${b} in ${d}` }); }
    }
    // significator field-house placement + dispositor chain
    for (const b of prof.sigs) {
      const hse = houseOf(fr.comp[b], nat.asc);
      if (prof.houses.includes(hse)) { factorScore += 0.6; hits.push({ val: 0.6, kind: 'house', txt: `${tag}: ${G[b]} ${b} in H${hse} — the activity's house` }); }
      else if ([1, 4, 7, 10].includes(hse)) { factorScore += 0.3; hits.push({ val: 0.3, kind: 'house', txt: `${tag}: ${G[b]} ${b} angular (H${hse})` }); }
      const disp = RULERS[signIndex(fr.comp[b])];
      const hseD = houseOf(fr.comp[disp], nat.asc);
      if ([1, 4, 7, 10].includes(hseD)) { factorScore += 0.25; hits.push({ val: 0.25, kind: 'house', txt: `${tag}: ${G[b]} ${b}'s dispositor ${G[disp]} ${disp} angular (H${hseD})` }); }
      else if (hseD === 6 || hseD === 12) { factorScore -= 0.25; hits.push({ val: -0.25, kind: 'house', txt: `${tag}: ${G[b]} ${b}'s dispositor ${G[disp]} ${disp} cadent-hidden (H${hseD})` }); }
    }
    // moment sect matches chart sect
    const momentNight = norm360(fr.moment.Sun - nat.asc) < 180;
    if (momentNight === !nat.isDay) { factorScore += 0.4; hits.push({ val: 0.4, kind: 'sect', txt: `${tag}: ${momentNight ? 'night' : 'day'} moment matches ${nat.isDay ? 'day' : 'night'} chart` }); }
    // void composite Moon (no applying aspect to the other frame)
    let moonApplies = false;
    for (const bb of BODIES) {
      const asp = aspectBetween(fr.comp.Moon, otherFr.comp[bb], orbMax);
      if (asp && fr2 && otherFr2 && isApplying(fr.comp.Moon, otherFr.comp[bb], fr2.comp.Moon, otherFr2.comp[bb], asp.angle, asp.orb)) { moonApplies = true; break; }
    }
    if (!moonApplies) {
      if (prof.invert) { factorScore += 0.8; hits.push({ val: 0.8, kind: 'void', txt: `${tag}: void composite Moon — field at rest` }); }
      else if (prof.initiating) { factorScore -= 0.9; hits.push({ val: -0.9, kind: 'void', txt: `${tag}: void composite Moon — nothing to carry it` }); }
    }
  }
  // mutual reception between the two composite sect lights — structural handshake
  const la = natA.sectLight, lb = natB.sectLight;
  if (la !== lb && RULERS[signIndex(frameA.comp[la])] === lb && RULERS[signIndex(frameB.comp[lb])] === la) {
    factorScore += 1.5;
    hits.push({ val: 1.5, kind: 'reception', txt: `mutual reception ${G[la]} ↔ ${G[lb]} — structural handshake` });
  }
  hits.sort((x, y) => Math.abs(y.val) - Math.abs(x.val));
  return { score: aspectScore + factorScore, hits };
}

// ---------- solo electional scoring: one person's live composite, no partner ----------
// pos/posN = transiting positions at jd and ~30min later (for applying tests)
export function scoreMomentSolo(natal, pos, posN, profileKey, orbMax = 3) {
  const prof = PROFILES[profileKey];
  const comp = {}, compN = {};
  for (const b of BODIES) { comp[b] = midpoint(natal.pos[b], pos[b]); compN[b] = midpoint(natal.pos[b], posN[b]); }
  const G = GLYPHS, hits = [];
  let score = 0;
  const applying = (l1, l2, l1n, l2n, angle) =>
    Math.abs(Math.abs(wrap180(l1n - l2n)) - angle) < Math.abs(Math.abs(wrap180(l1 - l2)) - angle);
  // Profile-driven weights: aspects not touching this activity's significators/holders
  // contribute nothing, so each activity has its own curve. Luminaries count lightly.
  const weightFor = b => prof.sigs.includes(b) ? 1.8 : prof.holders.includes(b) ? 1.3 : b === natal.sectLight ? 0.6 : (b === 'Sun' || b === 'Moon') ? 0.4 : 0;
  let aspScore = 0;
  // composite internal aspects (sig-involving only). SNode skipped: any aspect to it
  // mirrors one to the Node (180° apart) — counting both double-credits the same contact.
  for (let i = 0; i < BODIES.length; i++) for (let j = i + 1; j < BODIES.length; j++) {
    const b1 = BODIES[i], b2 = BODIES[j];
    if (b1 === 'SNode' || b2 === 'SNode') continue;
    const w = Math.max(weightFor(b1), weightFor(b2));
    if (!w) continue;
    const asp = aspectBetween(comp[b1], comp[b2], orbMax);
    if (!asp) continue;
    const app = applying(comp[b1], comp[b2], compN[b1], compN[b2], asp.angle);
    const val = w * (app ? 1 : 0.35) * Q[asp.angle] * (1 - asp.orb / orbMax);
    aspScore += val;
    hits.push({ val, txt: `${G[b1]} ${b1} ${asp.glyph} ${G[b2]} ${b2} · ${asp.orb.toFixed(1)}°${app ? ' applying' : ''}` });
  }
  // composite contacts to natal angles (sig-involving only; SNode mirrors Node)
  for (const b of BODIES) for (const [an, alon] of [['ASC', natal.asc], ['MC', natal.mc]]) {
    if (b === 'SNode') continue;
    const w = weightFor(b);
    if (!w) continue;
    const asp = aspectBetween(comp[b], alon, orbMax);
    if (!asp) continue;
    const val = 1.2 * w * Q[asp.angle] * (1 - asp.orb / orbMax);
    aspScore += val;
    hits.push({ val, txt: `${G[b]} ${b} ${asp.glyph} natal ${an} · ${asp.orb.toFixed(1)}°` });
  }
  if (prof.invert) { aspScore = -aspScore * 0.6; hits.forEach(hh => { hh.val = -hh.val * 0.6; }); }
  score += aspScore;
  // holders in profile houses / angular
  for (const b of prof.holders) {
    const hse = houseOf(comp[b], natal.asc);
    if (prof.houses.includes(hse)) { score += 0.7; hits.push({ val: 0.7, txt: `${G[b]} ${b} in H${hse} (profile house)` }); }
    else if ([1, 4, 7, 10].includes(hse)) { score += 0.35; hits.push({ val: 0.35, txt: `${G[b]} ${b} angular (H${hse})` }); }
  }
  // sig dispositor chain intact: each significator's dispositor also weighted
  for (const b of prof.sigs) {
    const disp = RULERS[signIndex(comp[b])];
    const hseD = houseOf(comp[disp], natal.asc);
    if ([1, 4, 7, 10].includes(hseD)) { score += 0.25; hits.push({ val: 0.25, txt: `${G[b]} ${b}'s dispositor ${G[disp]} ${disp} angular (H${hseD})` }); }
    if (hseD === 6 || hseD === 12) { score -= 0.25; hits.push({ val: -0.25, txt: `${G[b]} ${b}'s dispositor ${G[disp]} ${disp} cadent-hidden (H${hseD})` }); }
  }
  // moment sect matches chart sect
  const momentNight = norm360(pos.Sun - natal.asc) < 180;
  if (momentNight === !natal.isDay) { score += 0.3; hits.push({ val: 0.3, txt: `${momentNight ? 'night' : 'day'} moment matches ${natal.isDay ? 'day' : 'night'} chart` }); }
  // void composite Moon penalizes initiating activities
  if (prof.initiating) {
    let applies = false;
    for (const b of BODIES) {
      if (b === 'Moon') continue;
      const asp = aspectBetween(comp.Moon, comp[b], orbMax);
      if (asp && applying(comp.Moon, comp[b], compN.Moon, compN[b], asp.angle)) { applies = true; break; }
    }
    if (!applies) { score -= 0.7; hits.push({ val: -0.7, txt: 'composite ☽ Moon void (no applying aspect)' }); }
  }
  hits.sort((x, y) => Math.abs(y.val) - Math.abs(x.val));
  return { score, hits };
}
