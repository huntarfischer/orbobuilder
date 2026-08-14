// tympan.js · the Tympan: the twelve whole-sign frames, and the governance index.
//
// THE FIRST MEMBER OF THE CONNECTOME, AND INHERENT LIKE THE RING AND THE MATER. Twelve stampings,
// 144 rows forward and 144 reverse, stamped from constants at load, before anything asks. No native,
// no place, no time. It takes an ASC SIGN, never a lat/lon. A native's frame is one read of gene 1 at
// sign resolution: nothing is computed per native and nothing is stored per native, which is why the
// Tympan needs no persistence and no tabula. It is invisible infrastructure, and a native only ever
// sees their own stamping.
//
// Named for the astrolabe's engraved sheet under the rete that supplies the houses, swapped out to
// change which set applies. The honest disanalogy: a brass tympan swaps on LATITUDE, this one on
// RISING SIGN. It is NOT the composite frame, not the reading's frame rotation, and not framing.js.
//
// THE CONNECTOME IS BENEATH THE FACE. The sun/moon law is an information law about the FACE — what
// the native sees, and where a way of looking lands. It says nothing about code layering. Both faces
// read this table and neither owns it, exactly as both read the Ring.
//
// WHAT IT HOLDS:
//   1. HOUSE_FRAMES   · forward. frame + sign → house. Absorbed from the Mater (the frames MOVED
//                       here; the Mater does not keep a second set, and its own test now reads this
//                       file for them). One die, whichever file holds it.
//   2. SIGN_FRAMES    · the same 144 rows inverted. frame + house → sign.
//   3. RULES_HOUSES   · REVERSE. frame + planet → the houses it governs. THIS IS WHY THE FILE
//                       EXISTS. Forward is one line of arithmetic; reverse is content. The pane's
//                       sentence, the loom's `governed`, and above all the watcher doctrine, where
//                       each placement watches its CURRENT GOVERNOR rather than the engine scanning
//                       per body. The instrument hand-walked this twice (`for (let i=0;i<12;i++) if
//                       (_rulerOfSign(i)===name)`); a walk is not a lookup.
//   4. CO_RULES_HOUSES · the SEPARATE modern index. Three entries per frame, one house each.
//
// SEPARATE, NEVER A COLUMN. Traditional is the backbone: Scorpio's house has Mars as lord and Pluto
// as co-ruler, Aquarius Saturn with Uranus, Pisces Jupiter with Neptune. Held in its own index rather
// than as a column with a skip-flag, because then THE DISPOSITOR WALKER IS STRUCTURALLY INCAPABLE OF
// BRANCHING INTO A MODERN: it is never handed that table at all. A column you must remember to skip
// is a bug waiting for a tired afternoon. The native SEES both lords; the engines COUNT one.
//
// REFUSES: occupants · time · place · the Ring · aspects · orbs · sect · lots · decans · terms ·
// faces · triplicity · and HOUSE MEANING WORDS. The last is the one it will be pushed on hardest: if
// "the 3rd is siblings and short journeys" lives here, the Tympan becomes where doctrine text lives
// and it stops being inherent. THE TYMPAN GIVES THE NUMBER; A GLOSSARY READER GIVES THE WORD.
// Asserted by a word grep in tests/tympan.test.html, because a claim in a header enforces nothing.
//
// THE DIGNITY SEAM: the Tympan is sign → house → domicile lord. rulers.js stays degree → dignities
// (decans, terms, faces, triplicity rulership). connectome.js joins them. Nothing is duplicated.
//
// SELECTION IS NOT HOUSING. The rising-lord horizon scan and the composite chronology's cASC DO
// select other frames from the die, by a moving ASC. That is legal: they ask who governs a moving
// degree, not where to house a placement. Selection is cheap; housing is fixed.
//
// ERROR CONTRACT · THE RING'S, EXACTLY, because two sibling tables with opposite contracts is worse
// than either:
//   absence            → null   (Aries has no co-ruler)
//   well-formed, empty → []     (Mars co-rules nothing; an empty array is truthy, so a loose caller
//                                still behaves)
//   malformed address  → THROWS (house 13, sign 37, unknown planet)
// A throw cannot reach the database: the Tympan holds no user content, reads nothing from storage,
// writes nothing, and its inputs are ordinals and planet names from Orbo's own genome. A throw means
// a typo in Orbo's source, which fires the first time that line runs in development — and `_fuse`
// means a throwing layer costs one engraving, never the plate. ONE VALIDATOR PER ARGUMENT KIND, no
// exemption for flags, per the Ring's four review rounds.
//
// NUMBERING. A house is an ORDINAL (1-12) on the way in and on the way out, so 0 is never a valid
// answer and truthiness is safe on a house read BY CONSTRUCTION. A sign arrives as the 0-11 ADDRESS
// the rest of the codebase already speaks (mater.signIndexOf, framing.signIndex, astrodna's
// signIndex all produce it). The codec law calls a sign an ordinal, which the codebase has never
// implemented anywhere; migrating it is its own pass, and doing it inside a move whose acceptance is
// "nothing visible changes" is exactly how a silent off-by-one ships. Flagged in CLAUDE.md, not
// quietly entrenched here.
//
// It imports the Mater and nothing else. Verified in tests/tympan.test.html.

import { SIGNS, RULERS, DISPOSITORS, signIndexOf } from './mater.js';

// ---------- the validators · one per argument kind ----------
const isInt = (n) => typeof n === 'number' && Number.isInteger(n);

// A sign is a 0-11 address into the twelve. Malformed throws rather than normalizing: the Mater's
// old reads folded any integer with ((x%12)+12)%12, which silently answered for sign 37.
function signAddr(signIdx, who) {
  if (!isInt(signIdx) || signIdx < 0 || signIdx > 11) throw new Error('tympan: ' + who + ' needs a sign address 0-11, got ' + String(signIdx));
  return signIdx;
}
// A house is a 1-12 ordinal. House 13 is the canonical malformed address.
function houseOrd(house, who) {
  if (!isInt(house) || house < 1 || house > 12) throw new Error('tympan: ' + who + ' needs a house ordinal 1-12, got ' + String(house));
  return house;
}
// The seven that GOVERN. Anything else is a category mistake here, and the message says where to go,
// because the whole point of the split is that a caller cannot drift a modern into the backbone.
function governor(name, who) {
  if (!DISPOSITORS.includes(name)) throw new Error('tympan: ' + who + ' governs by the traditional seven and got ' + String(name) + (MODERNS.includes(name) ? '. A modern is a co-ruler: read housesCoRuledBy.' : '.'));
  return name;
}
// The ten Orbo names as a governor of any kind, for the co-ruler index only.
function anyGovernor(name, who) {
  if (!DISPOSITORS.includes(name) && !MODERNS.includes(name)) throw new Error('tympan: ' + who + ' needs one of the seven or one of the three moderns, got ' + String(name));
  return name;
}

// ---------- 1 · the twelve frames, forward ----------
// Whole-sign houses anchored to the ASC SIGN, always. A house read is a LOOKUP into a stamped row,
// not a modular rotation at the call site.
export const HOUSE_FRAMES = Object.freeze(SIGNS.map((_, asc) => Object.freeze(SIGNS.map((__, sg) => ((sg - asc + 12) % 12) + 1))));

// ---------- 2 · the same 144 rows, inverted ----------
// frame + house ordinal → sign address. Indexed `house - 1` in exactly one place, `signOfHouse`,
// which every other reader (including this file's own load-time check) goes through. Asserted by a
// source count in tests/tympan.test.html: an ordinal-to-index conversion at two call sites is how an
// off-by-one enters a table that is otherwise correct by construction.
export const SIGN_FRAMES = Object.freeze(SIGNS.map((_, asc) => Object.freeze(SIGNS.map((__, i) => (asc + i) % 12))));

// ---------- 3 · the reverse index · frame + planet → houses ----------
// Ascending house order, stamped rather than searched. Mercury, Venus, Mars, Jupiter and Saturn each
// hold two signs and therefore two houses in every frame; the Sun and the Moon hold one.
export const RULES_HOUSES = Object.freeze(HOUSE_FRAMES.map((frame) => Object.freeze(Object.fromEntries(
  DISPOSITORS.map((p) => [p, Object.freeze(RULERS.reduce((acc, r, sg) => (r === p ? acc.concat(frame[sg]) : acc), []).sort((a, b) => a - b))]),
))));

// ---------- 4 · the modern co-ruler index · SEPARATE ----------
// Sign address → co-ruler. Scorpio, Aquarius, Pisces. Every other sign has no co-ruler, and the
// absence is null.
export const MODERNS = Object.freeze(['Uranus', 'Neptune', 'Pluto']);
export const MODERN_RULERS = Object.freeze({ 7: 'Pluto', 10: 'Uranus', 11: 'Neptune' });
const MODERN_SIGNS = Object.freeze(Object.keys(MODERN_RULERS).map(Number));
export const CO_RULES_HOUSES = Object.freeze(HOUSE_FRAMES.map((frame) => Object.freeze(Object.fromEntries(
  // The seven appear here with an EMPTY array, not absent: "Mars co-rules nothing" is a well-formed
  // answer and the contract says [] for it.
  DISPOSITORS.concat(MODERNS).map((p) => [p, Object.freeze(MODERN_SIGNS.filter((sg) => MODERN_RULERS[sg] === p).map((sg) => frame[sg]).sort((a, b) => a - b))]),
))));

// ---------- the frame record ----------
// One frozen object per stamping, in house order, carrying only addresses, ordinals and lord names.
// This is the raw material of the Connectome's HouseNode; `rulerHouse` and `destinationHouse` are
// the compiler's, because they need occupants.
export const FRAMES = Object.freeze(SIGNS.map((_, asc) => Object.freeze({
  ascSign: asc,
  ascSignName: SIGNS[asc],
  houses: Object.freeze(SIGN_FRAMES[asc].map((sg, i) => Object.freeze({
    house: i + 1, signIndex: sg, sign: SIGNS[sg], ruler: RULERS[sg], coRuler: MODERN_RULERS[sg] || null,
  }))),
  rulesHouses: RULES_HOUSES[asc],
  coRulesHouses: CO_RULES_HOUSES[asc],
})));

// ---------- the reads ----------
export function frameOf(ascSignIdx) { return FRAMES[signAddr(ascSignIdx, 'frameOf')]; }
export function houseFrame(ascSignIdx) { return HOUSE_FRAMES[signAddr(ascSignIdx, 'houseFrame')]; }
export function houseOfSign(signIdx, ascSignIdx) { return HOUSE_FRAMES[signAddr(ascSignIdx, 'houseOfSign')][signAddr(signIdx, 'houseOfSign')]; }
// Takes two longitudes and reduces both to signs on the way in. It is not a place read: a body's
// longitude is a degree, and the Tympan still refuses a latitude, a coordinate pair and a moment.
export function houseOfLon(bodyLon, ascendantLon) { return houseOfSign(signIndexOf(bodyLon), signIndexOf(ascendantLon)); }
export function signOfHouse(house, ascSignIdx) { return SIGN_FRAMES[signAddr(ascSignIdx, 'signOfHouse')][houseOrd(house, 'signOfHouse') - 1]; }
export function rulerOfHouse(house, ascSignIdx) { return RULERS[signOfHouse(house, ascSignIdx)]; }
export function coRulerOfSign(signIdx) { return MODERN_RULERS[signAddr(signIdx, 'coRulerOfSign')] || null; }
export function coRulerOfHouse(house, ascSignIdx) { return coRulerOfSign(signOfHouse(house, ascSignIdx)); }
// The reverse read. Never empty for the seven — every one of them governs at least one house in
// every frame — and that is a fact of the table, not a promise this accessor makes.
export function housesRuledBy(planet, ascSignIdx) { return RULES_HOUSES[signAddr(ascSignIdx, 'housesRuledBy')][governor(planet, 'housesRuledBy')]; }
export function housesCoRuledBy(planet, ascSignIdx) { return CO_RULES_HOUSES[signAddr(ascSignIdx, 'housesCoRuledBy')][anyGovernor(planet, 'housesCoRuledBy')]; }

// ---------- the flip law, free from the geometry ----------
// A synchronic placement lives in the 180° arc centred on its natal degree, so a flip moves it
// exactly six signs — and under the natal whole-sign law a sign boundary IS a house boundary, so it
// moves exactly SIX HOUSES, always, in every frame. Stated as a function because doctrine reads it,
// and asserted at stamp time below.
export const FLIP_HOUSES = 6;
export function flipHouse(house) { return ((houseOrd(house, 'flipHouse') - 1 + FLIP_HOUSES) % 12) + 1; }

// ---------- the load-time completeness check ----------
// The Mater's and the Ring's idiom: an invariant enforced by CODE at load, never asserted in a
// comment and never yielding undefined at the moment a reader is reading.
(function stamp() {
  const who = 'tympan: ';
  if (HOUSE_FRAMES.length !== 12 || SIGN_FRAMES.length !== 12) throw new Error(who + 'the die is twelve stampings');
  for (let asc = 0; asc < 12; asc++) {
    const frame = HOUSE_FRAMES[asc];
    if (frame.length !== 12) throw new Error(who + 'frame ' + asc + ' is not twelve houses');
    if (frame[asc] !== 1) throw new Error(who + 'frame ' + asc + ' is not anchored to its own ASC sign');
    const seen = new Set();
    for (let sg = 0; sg < 12; sg++) {
      if (frame[sg] !== ((sg - asc + 12) % 12) + 1) throw new Error(who + 'frame ' + asc + ' sign ' + sg + ' disagrees with the whole-sign rotation it replaced');
      if (frame[sg] < 1 || frame[sg] > 12) throw new Error(who + 'frame ' + asc + ' yields house ' + frame[sg] + ', which is not an ordinal 1-12');
      seen.add(frame[sg]);
      // the inversion is the same 144 rows read the other way, so it must round-trip both
      // directions — THROUGH THE READ, so the ordinal-minus-one lives in exactly one place
      if (signOfHouse(frame[sg], asc) !== sg) throw new Error(who + 'frame ' + asc + ' does not invert at sign ' + sg);
    }
    if (seen.size !== 12) throw new Error(who + 'frame ' + asc + ' does not hold each house exactly once');
    // forward and reverse are one table read two ways: every house is governed, and the seven
    // between them account for all twelve with nothing doubled.
    let total = 0;
    for (const p of DISPOSITORS) {
      const hs = RULES_HOUSES[asc][p];
      if (!Object.isFrozen(hs)) throw new Error(who + 'the reverse index for ' + p + ' is mutable');
      for (const h of hs) if (rulerOfHouse(h, asc) !== p) throw new Error(who + p + ' is indexed against house ' + h + ' of frame ' + asc + ', which it does not govern');
      total += hs.length;
    }
    if (total !== 12) throw new Error(who + 'frame ' + asc + ' reverse index accounts for ' + total + ' houses, not twelve');
    // the co-rulership boundary, enforced rather than commented
    for (const p of DISPOSITORS) if (CO_RULES_HOUSES[asc][p].length) throw new Error(who + p + ' is one of the seven and cannot co-rule');
    for (const p of MODERNS) {
      if (RULES_HOUSES[asc][p] !== undefined) throw new Error(who + 'modern ' + p + ' reached the traditional reverse index, which is the one thing the split exists to prevent');
      if (CO_RULES_HOUSES[asc][p].length !== 1) throw new Error(who + p + ' co-rules ' + CO_RULES_HOUSES[asc][p].length + ' houses in frame ' + asc + ', not one');
    }
  }
  for (const sg of MODERN_SIGNS) if (RULERS[sg] === MODERN_RULERS[sg]) throw new Error(who + 'a modern reached the Mater\u2019s traditional table');
  // the flip law
  for (let h = 1; h <= 12; h++) {
    const f = flipHouse(h);
    if (flipHouse(f) !== h) throw new Error(who + 'the flip is not an involution at house ' + h);
    if (Math.min(Math.abs(f - h), 12 - Math.abs(f - h)) !== FLIP_HOUSES) throw new Error(who + 'the flip does not move house ' + h + ' exactly six houses');
  }
})();
