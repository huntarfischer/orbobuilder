// mater.browser.js · auto-generated browser-global build of mater.js (no ES modules; assigns window.__ORBO_MATER).
// Source of truth is mater.js. Regenerate this file if mater.js changes, don't hand-edit.
// Load order: FIRST, beside ring.browser.js. The Mater imports nothing, so it has no dependency guard.
// The twelve house frames moved to tympan.browser.js, which loads after this file.
(function boot(){
// mater.js · the Mater: the inherent MEANING of the twelve signs.
//
// A SIBLING OF THE RING, AND NEVER A PART OF IT. The Ring's law says it knows nothing of signs,
// elements, decans, terms, faces or rulers, so rulership cannot go inside it. THE RING IS THE
// INHERENT RELATION; THE MATER IS THE INHERENT MEANING. Both are stamped before the app runs, both
// need no person, no place and no time, and both are ARTIFACTS rather than generators. This is the
// fourth tier ring.js named: INHERENT. True before the app runs.
//
// ON THE NAME. `frame` was spoken for (composite framing, and the twelve house frames are only one
// of five tables here). Skeleton, chassis and structure are engineering words in an instrument that
// otherwise speaks brass: aegis, tabula, rete, limb, plate. The mater is the astrolabe's own body,
// the dished disc that is engraved once and into which every plate seats. It says the thing
// everything else sits in, and it pairs with the Ring as an object rather than as a metaphor.
//
// FOUR STAMPED TABLES, all pure, no arguments, no time, no native:
//   1. signs           · twelve names, glyphs, elements, modalities
//   2. rulership       · traditional, the backbone
//   3. exaltation      · sign AND exact degree
//   4. detriment/fall  · derived at STAMP time as the oppositions of 2 and 3, then frozen, so the
//                        derivation happens once and readers get a table
//
// THE HOUSE FRAMES LEFT (2026-08-05, the Connectome pass). They were table 3 here, as the FORWARD
// stamping only; tympan.js absorbed them and added what this file deferred — the REVERSE index
// (frame + planet → the houses it governs) and the separate modern co-ruler index. ONE DIE,
// WHICHEVER FILE HOLDS IT, so nothing is stamped twice: readers that want a house read tympan.js,
// and tests/mater.test.html asserts the frames are NOT here rather than checking them here.
//
// THE CO-RULERSHIP BOUNDARY IS A LANDMINE AND SURVIVES VERBATIM. There is NO modern attribution in
// this file. Pluto, Uranus and Neptune are DISPLAY co-rulers and live in one sibling table in the
// instrument (the DC's CO_RULER), consumed by the lord row in the body readouts and nowhere else.
// Merging any of them into RULERS here would silently rewrite dignity, disposition chains, the
// rules-houses loops, ZR period lengths and the election engine, because those techniques are
// defined on the traditional set. The native SEES both lords; the engines COUNT one. Asserted in
// tests/mater.test.html and in tests/rewire-parity.test.html.
//
// It imports nothing (the Ring's own rule for a floor), and it is the one authority for what it
// holds: framing.js, astrodna.js, rulers.js and the instrument all read it rather than carrying
// their own copy. Verified in tests/mater.test.html.

const norm360 = (d) => ((d % 360) + 360) % 360;

// ---------- 1 · the signs ----------
const SIGNS = Object.freeze(['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces']);
const SIGN_GLYPHS = Object.freeze(['\u2648', '\u2649', '\u264A', '\u264B', '\u264C', '\u264D', '\u264E', '\u264F', '\u2650', '\u2651', '\u2652', '\u2653']);
// The element and modality cycles ARE the zodiac's construction: element repeats every four signs
// from Aries, modality every three. Stated as the cycle rather than typed out twelve times, so the
// two cannot fall out of step with the sign order above.
const ELEMENTS = Object.freeze(['fire', 'earth', 'air', 'water']);
const MODALITIES = Object.freeze(['cardinal', 'fixed', 'mutable']);

const SIGN_INDEX = Object.freeze(Object.fromEntries(SIGNS.map((s, i) => [s, i])));
const SIGN_ELEMENT = Object.freeze(SIGNS.map((_, i) => ELEMENTS[i % 4]));
const SIGN_MODALITY = Object.freeze(SIGNS.map((_, i) => MODALITIES[i % 3]));
// name-keyed element, the shape astrodna.js reads.
const SIGN_ELEMENTS = Object.freeze(Object.fromEntries(SIGNS.map((s, i) => [s, ELEMENTS[i % 4]])));
const SIGN_TABLE = Object.freeze(SIGNS.map((name, i) => Object.freeze({
  index: i, name, glyph: SIGN_GLYPHS[i],
  element: ELEMENTS[i % 4], elementIndex: i % 4,
  modality: MODALITIES[i % 3], modalityIndex: i % 3,
})));

// ---------- 2 · rulership, traditional ----------
// Mars/Scorpio, Saturn/Aquarius, Jupiter/Pisces. The backbone. Moderns are co-governors and never
// chain branches, so they are not here (see the header).
const RULERS = Object.freeze(['Mars', 'Venus', 'Mercury', 'Moon', 'Sun', 'Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'Saturn', 'Jupiter']);
// name-keyed, the shape rulers.js and astrodna.js read.
const DOMICILE = Object.freeze(Object.fromEntries(SIGNS.map((s, i) => [s, RULERS[i]])));
// Only the seven classical planets dispose; everything else (Asc, nodes, outers, asteroids, lots) is
// disposed but never a dispositor. Traditional law, and it keeps the graph closed.
const DISPOSITORS = Object.freeze(['Sun', 'Moon', 'Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn']);
// Which signs each planet rules, stamped rather than searched (Mercury and Venus, Mars, Jupiter and
// Saturn each hold two).
const RULES_SIGNS = Object.freeze(Object.fromEntries(DISPOSITORS.map((p) => [p, Object.freeze(RULERS.reduce((o, r, i) => (r === p ? o.concat(i) : o), []))])));

// ---------- 3 · exaltation, sign AND degree ----------
// The classical seven, with their traditional degrees. Sun 19 Aries, Moon 3 Taurus, and the rest.
// The DEGREE is a Mater lookup applied live at the reading; sign-level dignity is what an Expression
// carries (the Expression is sign resolution, by law).
const EXALT = Object.freeze({ Sun: 0, Moon: 1, Mercury: 5, Venus: 11, Mars: 9, Jupiter: 3, Saturn: 6 });
const EXALT_DEGREE = Object.freeze({ Sun: 19, Moon: 3, Mercury: 15, Venus: 27, Mars: 28, Jupiter: 15, Saturn: 21 });
// sign-keyed, the shape rulers.js reads.
const EXALTATION = Object.freeze(Object.fromEntries(Object.keys(EXALT).map((p) => [SIGNS[EXALT[p]], Object.freeze({ planet: p, degree: EXALT_DEGREE[p] })])));
const EXALT_BY_SIGN = Object.freeze(SIGNS.map((s) => (EXALTATION[s] ? EXALTATION[s].planet : null)));

// ---------- 4 · detriment and fall, derived at stamp time then frozen ----------
// Detriment = the sign opposite one of the planet's own domiciles; fall = the sign opposite its
// exaltation. Derived ONCE here so every reader gets a table instead of running the opposition.
const DETRIMENT_BY_SIGN = Object.freeze(SIGNS.map((_, i) => RULERS[(i + 6) % 12]));
const FALL_BY_SIGN = Object.freeze(SIGNS.map((_, i) => EXALT_BY_SIGN[(i + 6) % 12]));
const DETRIMENT = Object.freeze(Object.fromEntries(DISPOSITORS.map((p) => [p, Object.freeze(RULES_SIGNS[p].map((i) => (i + 6) % 12))])));
const FALL = Object.freeze(Object.fromEntries(Object.keys(EXALT).map((p) => [p, (EXALT[p] + 6) % 12])));

// ---------- the reads ----------
const signIndexOf = (lon) => Math.floor(norm360(lon) / 30) % 12;
const signNameOf = (lon) => SIGNS[signIndexOf(lon)];
const glyphOf = (signIdx) => SIGN_GLYPHS[((signIdx % 12) + 12) % 12];
const elementOf = (signIdx) => SIGN_ELEMENT[((signIdx % 12) + 12) % 12];
const modalityOf = (signIdx) => SIGN_MODALITY[((signIdx % 12) + 12) % 12];
const rulerOf = (signIdx) => RULERS[((signIdx % 12) + 12) % 12];
// Sign-level essential dignity, in ONE vocabulary: domicile · exaltation · detriment · fall · null.
// Callers that speak differently (rulers.js says exalt and peregrine) translate at their own edge
// rather than each running the ladder again. Traditional table only, by the co-rulership law.
function dignityOfSign(planet, signIdx) {
  const i = ((signIdx % 12) + 12) % 12;
  if (RULERS[i] === planet) return 'domicile';
  if (EXALT_BY_SIGN[i] === planet) return 'exaltation';
  if (DETRIMENT_BY_SIGN[i] === planet) return 'detriment';
  if (FALL_BY_SIGN[i] === planet) return 'fall';
  return null;
}
const dignityOfLon = (planet, lon) => dignityOfSign(planet, signIndexOf(lon));

// ---------- the load-time completeness check ----------
// Same idiom as the Ring and as every table this rewire touched: an invariant enforced by code at
// LOAD, never asserted in a comment and never yielding undefined at the moment a reader is reading.
(function stamp() {
  const who = 'mater: ';
  if (SIGNS.length !== 12 || SIGN_GLYPHS.length !== 12) throw new Error(who + 'the zodiac is twelve');
  for (let i = 0; i < 12; i++) {
    if (!SIGNS[i] || !SIGN_GLYPHS[i]) throw new Error(who + 'sign ' + i + ' has no name or no glyph');
    if (!ELEMENTS.includes(SIGN_ELEMENT[i])) throw new Error(who + 'sign ' + i + ' has no element');
    if (!MODALITIES.includes(SIGN_MODALITY[i])) throw new Error(who + 'sign ' + i + ' has no modality');
    if (!DISPOSITORS.includes(RULERS[i])) throw new Error(who + SIGNS[i] + ' is ruled by ' + RULERS[i] + ', which is not one of the classical seven. A modern co-ruler in this table rewrites dignity, the chains, ZR and the election engine.');
  }
  for (const p of Object.keys(EXALT)) {
    if (EXALT_DEGREE[p] == null) throw new Error(who + p + ' is exalted with no degree');
    if (!DISPOSITORS.includes(p)) throw new Error(who + p + ' is exalted but does not dispose');
  }
  // three elements of four appear three times, three modalities four times: the cycles, checked.
  for (const e of ELEMENTS) if (SIGN_ELEMENT.filter((x) => x === e).length !== 3) throw new Error(who + e + ' does not hold three signs');
  for (const m of MODALITIES) if (SIGN_MODALITY.filter((x) => x === m).length !== 4) throw new Error(who + m + ' does not hold four signs');
})();

window.__ORBO_MATER = { SIGNS, SIGN_GLYPHS, ELEMENTS, MODALITIES, SIGN_INDEX, SIGN_ELEMENT, SIGN_MODALITY, SIGN_ELEMENTS, SIGN_TABLE, RULERS, DOMICILE, DISPOSITORS, RULES_SIGNS, EXALT, EXALT_DEGREE, EXALTATION, EXALT_BY_SIGN, DETRIMENT_BY_SIGN, FALL_BY_SIGN, DETRIMENT, FALL, signIndexOf, signNameOf, glyphOf, elementOf, modalityOf, rulerOf, dignityOfSign, dignityOfLon };
})();
