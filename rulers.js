// rulers.js — LAYER 1 ONLY: rulership, the law. degree → its lord. Pointwise, chart-independent,
// timeless. Traditional (pre-modern) domiciles — same table as astrodna.js — plus classical
// exaltations.
//
// THE DIGNITY LADDER IS BUILT (2026-08-05, the ladder pass). The slots stood empty for months and a
// spec claimed them as "already computed", which was false against these files; the review caught it,
// and this is the pass that makes the claim true. FIVE RUNGS, the classical ladder in order:
//   domicile · exaltation · triplicity (the element's three lords) · bound (term) · face (decan)
// plus the debilities (detriment, fall) the Mater already stamps, and `peregrine` for a planet
// holding NONE of the five. Only the seven classical planets are on the ladder: it is their table,
// and a modern in a bound is a category mistake, not a missing row.
//
// SIGN RESOLUTION IS THE MATER'S; EVERYTHING BELOW THE SIGN IS THIS FILE'S. The Mater's four tables
// are all twelve rows long and stop at the sign. A bound is 1 of 60 arcs and a face is 1 of 36, so
// they are sub-sign meaning and they live here, on the pointwise dignity layer the dignity seam
// already named (CLAUDE.md: "the Tympan is sign → house → domicile lord, rulers.js stays degree →
// dignities, the Connectome joins them"). Nothing is duplicated and nothing moved.
//
// THE SOURCES ARE RULED, not chosen here: `uploads/Orbo Traditions.md` sets Orbo's default profile as
// EGYPTIAN bounds and DOROTHEAN triplicity rulers, and the faces are the Chaldean order, which the
// traditions do not dispute. The Ptolemaic bounds are named there as the alternate and are NOT built:
// a second table means a doctrine switch, a doctrine switch changes `_doctrineKey`, and that rebuilds
// every fertilized century in the field. It is a ruling worth paying for on its own day.
//
// REFUSES A SCORE. There is no almuten, no dignity points, no "how dignified" number. Five rungs are
// five facts; which of them outweighs which is a judgment, and judgment belongs to the interpretation
// packs. The forbidden-word grep in tests/rulers.test.html holds the line.
//
// LAYER 2 — DISPOSITION (a chart's rulership graph: chains, cycles, receptions) MOVED OUT to
// dispositor.js, 2026-08-05 (specs/The Connectome Pass.md, 5.3). That file's input is an
// occupant-to-sign MAP, not a longitude map, and it is the sign-resolution walker every layer
// (natal, synchronic, composite, mundane) now shares. `disposition`, `lonsFromDna` and
// `dispositionFromDna` are DELETED here, not parked — dead in the app path, and the codebase's own
// law is delete rather than leave a fallback that drifts. Their reception logic (exaltation and
// mixed reception) moved to `dispositor.receptions`.
//
// One dependency, and it is the floor: the Mater, the inherent MEANING of the twelve signs
// (tests/rulers.test.html, tests/mater.test.html). The sign names, the domiciles and the
// exaltations were typed out here, a fourth and third copy of tables the app holds once now.
import { SIGNS, DOMICILE, EXALTATION, DISPOSITORS, dignityOfSign, elementOf } from './mater.js';

export { SIGNS, DOMICILE, EXALTATION, DISPOSITORS };

// Detriment = the sign opposite one of the planet's own domiciles; fall = the sign opposite
// its exaltation. Both are stamped tables on the Mater now, derived once at load, so this read
// is a lookup rather than a search over twelve signs per call. This engine's own vocabulary is
// kept verbatim at the edge: `exalt` rather than exaltation, and `peregrine` rather than null.
export function dignityOf(planet, lonDeg) {
  const d = dignityOfSign(planet, lordOf(lonDeg).signIndex);
  return d === 'exaltation' ? 'exalt' : (d || 'peregrine');
}

function norm(x) { x %= 360; return x < 0 ? x + 360 : x; }

// ── Layer 1 — rulership: who lords this degree ─────────────────────────────
export function lordOf(lonDeg) {
  const L = norm(lonDeg);
  const idx = Math.floor(L / 30);
  const sign = SIGNS[idx];
  const ex = EXALTATION[sign] || null;
  return { sign, signIndex: idx, degreeInSign: L - idx * 30, ruler: DOMICILE[sign], exalted: ex ? ex.planet : null, exaltDegree: ex ? ex.degree : null };
}

// Parity helper with astrodna.chartRuler: the Ascendant sign's domicile lord.
export function chartRulerOf(dna) { return lordOf(dna.nodes.Ascendant.longitude).ruler; }

// ── the bounds · EGYPTIAN, the broader practical transmission ───────────────
// Five bounds a sign, sixty in the zodiac, written as [lord, the degree it ENDS at] so the row reads
// the way the classical tables print. The Sun and the Moon hold no bound in this scheme: that is the
// scheme's own fact, not an omission, and the stamp below asserts it.
export const EGYPTIAN_BOUNDS = Object.freeze([
  [['Jupiter', 6], ['Venus', 12], ['Mercury', 20], ['Mars', 25], ['Saturn', 30]],   // Aries
  [['Venus', 8], ['Mercury', 14], ['Jupiter', 22], ['Saturn', 27], ['Mars', 30]],   // Taurus
  [['Mercury', 6], ['Jupiter', 12], ['Venus', 17], ['Mars', 24], ['Saturn', 30]],   // Gemini
  [['Mars', 7], ['Venus', 13], ['Mercury', 19], ['Jupiter', 26], ['Saturn', 30]],   // Cancer
  [['Jupiter', 6], ['Venus', 11], ['Saturn', 18], ['Mercury', 24], ['Mars', 30]],   // Leo
  [['Mercury', 7], ['Venus', 17], ['Jupiter', 21], ['Mars', 28], ['Saturn', 30]],   // Virgo
  [['Saturn', 6], ['Mercury', 14], ['Jupiter', 21], ['Venus', 28], ['Mars', 30]],   // Libra
  [['Mars', 7], ['Venus', 11], ['Mercury', 19], ['Jupiter', 24], ['Saturn', 30]],   // Scorpio
  [['Jupiter', 12], ['Venus', 17], ['Mercury', 21], ['Saturn', 26], ['Mars', 30]],  // Sagittarius
  [['Mercury', 7], ['Jupiter', 14], ['Venus', 22], ['Saturn', 26], ['Mars', 30]],   // Capricorn
  [['Mercury', 7], ['Venus', 13], ['Jupiter', 20], ['Mars', 25], ['Saturn', 30]],   // Aquarius
  [['Venus', 12], ['Jupiter', 16], ['Mercury', 19], ['Mars', 28], ['Saturn', 30]],  // Pisces
].map((row) => Object.freeze(row.map((b) => Object.freeze({ planet: b[0], end: b[1] })))));

// ── the faces · the Chaldean order, thirty-six decans ──────────────────────
// STAMPED FROM THE CYCLE, not typed out: the faces are the Chaldean sequence starting at Mars on 0°
// Aries, repeating every seven. Typing thirty-six rows out by hand would be thirty-six chances to
// disagree with a rule that has none. The stamp asserts the four corners of the classical table.
export const CHALDEAN = Object.freeze(['Saturn', 'Jupiter', 'Mars', 'Sun', 'Venus', 'Mercury', 'Moon']);
export const FACES = Object.freeze(Array.from({ length: 36 }, (_, i) => CHALDEAN[(CHALDEAN.indexOf('Mars') + i) % 7]));

// ── the triplicities · DOROTHEAN, three lords a group ──────────────────────
// TRIPLICITY IS THE ELEMENT GROUPING: groups of THREE signs, so four groups. (Quadruplicity is groups
// of four, so three groups, which is the modality. The number in the name is the size of the group,
// and the two get swapped constantly.) The day lord rules by day, the night lord by night, and the
// participating lord rules with both.
export const TRIPLICITY = Object.freeze({
  fire: Object.freeze({ day: 'Sun', night: 'Jupiter', participating: 'Saturn' }),
  earth: Object.freeze({ day: 'Venus', night: 'Moon', participating: 'Mars' }),
  air: Object.freeze({ day: 'Saturn', night: 'Mercury', participating: 'Jupiter' }),
  water: Object.freeze({ day: 'Venus', night: 'Mars', participating: 'Moon' }),
});

// ── the reads · one per rung, each a lookup ────────────────────────────────
// A bound is [start, end) in its own sign, so 6°00′ Aries is Venus's and not Jupiter's. Absence is
// null: a longitude always has a bound, so null here means a malformed table, never a valid answer.
export function boundOf(lonDeg) {
  const L = norm(lonDeg), idx = Math.floor(L / 30), deg = L - idx * 30;
  const row = EGYPTIAN_BOUNDS[idx];
  for (let i = 0; i < row.length; i++) {
    if (deg < row[i].end) return { planet: row[i].planet, start: i ? row[i - 1].end : 0, end: row[i].end, signIndex: idx, scheme: 'Egyptian' };
  }
  return null;
}
// The face is ten degrees, so the index is the decan of the zodiac, 0-35.
export function faceOf(lonDeg) {
  const L = norm(lonDeg), i = Math.floor(L / 10);
  return { planet: FACES[i], index: i, start: i * 10, end: i * 10 + 10, decanOfSign: Math.floor((L % 30) / 10) + 1 };
}
// Sect is an ARGUMENT, never derived here: this file has no chart, no horizon and no Sun. `isDay`
// null returns the group with no lord selected, which is the honest answer for a placeless field.
export function triplicityOf(signIdx, isDay) {
  const el = elementOf(((signIdx % 12) + 12) % 12);
  const t = TRIPLICITY[el];
  return { element: el, day: t.day, night: t.night, participating: t.participating, lord: isDay == null ? null : (isDay ? t.day : t.night), scheme: 'Dorothean' };
}
export function triplicityOfLon(lonDeg, isDay) { return triplicityOf(Math.floor(norm(lonDeg) / 30), isDay); }

// ── the ladder · the five rungs a planet holds at a degree ─────────────────
// Facts, in classical order, and NO SCORE. `rungs` is what the planet holds; `debility` is what the
// Mater already stamps against it; `peregrine` is true when the five are empty, which is the word's
// actual meaning and the only vocabulary this file adds.
export function ladderOf(planet, lonDeg, isDay) {
  if (!DISPOSITORS.includes(planet)) return null; // the ladder is the seven's own table
  const idx = Math.floor(norm(lonDeg) / 30), sign = SIGNS[idx];
  const ex = EXALTATION[sign] || null;
  const bound = boundOf(lonDeg), face = faceOf(lonDeg), tri = triplicityOf(idx, isDay);
  const rungs = [];
  if (DOMICILE[sign] === planet) rungs.push({ rung: 'domicile' });
  if (ex && ex.planet === planet) rungs.push({ rung: 'exaltation', degree: ex.degree });
  if (tri.lord === planet) rungs.push({ rung: 'triplicity', role: isDay ? 'day' : 'night', scheme: tri.scheme });
  else if (tri.participating === planet) rungs.push({ rung: 'triplicity', role: 'participating', scheme: tri.scheme });
  if (bound && bound.planet === planet) rungs.push({ rung: 'bound', start: bound.start, end: bound.end, scheme: bound.scheme });
  if (face.planet === planet) rungs.push({ rung: 'face', decan: face.decanOfSign });
  const d = dignityOfSign(planet, idx);
  return {
    planet, signIndex: idx, sign, rungs: Object.freeze(rungs),
    debility: (d === 'detriment' || d === 'fall') ? d : null,
    peregrine: rungs.length === 0,
    bound, face, triplicity: tri,
  };
}

// ── the load-time stamp · the tables' own invariants, enforced by code ──────
// The Mater's and the Ring's idiom. A bounds table is exactly the kind of hand-typed thing that is
// wrong in one cell and plausible everywhere, and the Egyptian scheme has arithmetic that catches it:
// the five arcs of a sign must close at 30, and each of the five planets holds exactly twelve bounds
// totalling its own known degree count (Saturn 57 · Jupiter 79 · Mars 66 · Venus 82 · Mercury 76,
// which sum to the whole circle).
(function stamp() {
  const who = 'rulers: ';
  if (EGYPTIAN_BOUNDS.length !== 12) throw new Error(who + 'the bounds are twelve rows');
  const count = {}, degrees = {};
  for (let sg = 0; sg < 12; sg++) {
    const row = EGYPTIAN_BOUNDS[sg];
    if (row.length !== 5) throw new Error(who + SIGNS[sg] + ' has ' + row.length + ' bounds, not five');
    if (row[4].end !== 30) throw new Error(who + SIGNS[sg] + ' bounds close at ' + row[4].end + ', not 30');
    let prev = 0;
    const seen = new Set();
    for (const b of row) {
      if (!(b.end > prev)) throw new Error(who + SIGNS[sg] + ' bounds do not ascend at ' + b.planet);
      if (b.planet === 'Sun' || b.planet === 'Moon') throw new Error(who + 'the Egyptian bounds give the lights no bound, and ' + SIGNS[sg] + ' hands one to the ' + b.planet);
      if (seen.has(b.planet)) throw new Error(who + b.planet + ' holds two bounds in ' + SIGNS[sg]);
      seen.add(b.planet);
      count[b.planet] = (count[b.planet] || 0) + 1;
      degrees[b.planet] = (degrees[b.planet] || 0) + (b.end - prev);
      prev = b.end;
    }
  }
  const TOTALS = { Saturn: 57, Jupiter: 79, Mars: 66, Venus: 82, Mercury: 76 };
  let all = 0;
  for (const p of Object.keys(TOTALS)) {
    if (count[p] !== 12) throw new Error(who + p + ' holds ' + count[p] + ' bounds, not twelve');
    if (degrees[p] !== TOTALS[p]) throw new Error(who + p + ' holds ' + degrees[p] + '° of bounds, not ' + TOTALS[p] + '°');
    all += degrees[p];
  }
  if (all !== 360) throw new Error(who + 'the bounds cover ' + all + '°, not the circle');
  // the faces, at the four corners of the classical table
  if (FACES.length !== 36) throw new Error(who + 'the faces are thirty-six');
  const corner = { 0: 'Mars', 2: 'Venus', 3: 'Mercury', 35: 'Mars', 18: 'Moon', 17: 'Mercury' };
  for (const i of Object.keys(corner)) if (FACES[i] !== corner[i]) throw new Error(who + 'face ' + i + ' is ' + FACES[i] + ', and the Chaldean order says ' + corner[i]);
  // the triplicities: four groups, three lords each, every lord one of the seven, and the keys are
  // the MATER'S OWN element words (lowercase) so `elementOf` indexes this table directly
  const els = Object.keys(TRIPLICITY);
  if (els.length !== 4) throw new Error(who + 'triplicity is the ELEMENT grouping: four groups of three signs');
  for (let sg = 0; sg < 12; sg++) if (!TRIPLICITY[elementOf(sg)]) throw new Error(who + SIGNS[sg] + "'s element has no triplicity group");
  for (const el of els) for (const role of ['day', 'night', 'participating']) {
    if (!DISPOSITORS.includes(TRIPLICITY[el][role])) throw new Error(who + el + "'s " + role + ' lord is not one of the seven');
  }
})();
