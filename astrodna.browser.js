// astrodna.browser.js — auto-generated browser-global build of astrodna.js (no ES modules; assigns window.__ORBO_ASTRODNA).
// Source of truth is astrodna.js — regenerate this file if astrodna.js changes, don't hand-edit.
// Load order: after ephem.browser.js, ring.browser.js and mater.browser.js.
(function boot(){
// Bundle-safety: inlined blob scripts don't preserve <script> order, so wait for deps
// (see CLAUDE.md — browser-build-only guard, no analog in the ES-module source).
if(!window.__ORBO_EPH || !window.__ORBO_RING || !window.__ORBO_MATER || !window.__ORBO_TYMPAN){return void setTimeout(boot,0);}
const { positions, angles, norm360, wrap180, vertex } = window.__ORBO_EPH;
const { MARKS, separation, arcOf, ARCSEC, arcsecOf, fineStateOf, stateOfFine } = window.__ORBO_RING;
const { SIGNS, SIGN_ELEMENTS, DOMICILE } = window.__ORBO_MATER;
const { houseOfSign } = window.__ORBO_TYMPAN;
// astrodna.js — AstroDNA encoder: the canonical natal genome. Zodiacal releasing, the
// timespine, and — eventually — the app's other interpretive engines are meant to DECODE
// from this, rather than each re-deriving positions independently from raw ephemeris.
//
// Ported from the user's astrodna.py sequencer (12-node numerical sequence, aspects,
// stelliums, elemental balance, chart ruler) onto this project's own ephemeris (ephem.js)
// in place of Swiss Ephemeris — same node set, same order, same encoding scheme.
//
// THE ENCODING (rewire step F, 2026-08-04; widened to arcseconds 2026-08-04, SEQ_CODEC 3). Each of
// the 12 nodes collapses to one Ring FINE STATE: arcseconds of the circle, 0–1,295,999 for direct
// motion or 1,296,000–2,591,999 for retrograde. The address is the Ring's own (`ring.fineStateOf`),
// so this file owns no encoding at all: the local encodeValue is long gone and step F's whole-degree
// `stateOf` gave way to the same shape scaled.
//
// WHY THE GENE GOT FINER. A resonator can prevent drift, detect loss and re-align a derived state,
// but it cannot recover arcminutes that were never encoded. The precision was never actually lost —
// `nodes` has always carried the full-precision float — what was lost was precision IN THE IDENTITY,
// and doctrine says two moments that engrave the same genome ARE the same chart. At whole degrees
// that claim was not quite true: a whole-degree Ascendant pins a moment only to about four minutes of
// clock. At arcseconds it is. This is also what the L1/L2/L3 ladder needs to be able to say 21°
// Aries, then 21° 08′, then 21° 08′ 37″ without a second source of truth for the digits.
//
// ARCSECONDS, NOT PACKED DIGITS. A gene of 0210837 would be a display format promoted to storage: it
// is not arithmetic (no reader could subtract two of them to get a separation), it admits invalid
// states (61 minutes encodes fine), and it drops the sign index unless prefixed. One absolute integer
// arcsecond of the circle keeps every operation a subtraction, and since all eleven marks are whole
// degrees they are all whole arcseconds: the perfect lattice survives at 3600x resolution.
//
// THE COARSE STATE IS STILL RIGHT THERE, AND IT IS WHAT CACHE KEYS USE. `degreeSequence` /
// `degreeSequenceString` project every gene back through `ring.stateOfFine`, and that projection is
// BYTE-IDENTICAL to what `sequenceString` returned under codec 2. So a finer genome costs not one
// artifact rebuild: the spine seed and fertKey file under the projection, because a century-long
// weave does not move for one arcsecond. A key is a deliberate cut at the resolution the artifact's
// contents are sensitive to, and it is named as one.
//
// SEQ_CODEC IS THE VERSION STAMP, AND A SEQUENCE IS NEVER SNIFFED. A sequence containing 720 is old
// and one containing 0 is new, but every other sequence is ambiguous, and after the reorder position
// no longer identifies a body either. So a persisted sequence carries the codec it was written under
// and a stale row is re-derived (the DC's _backfillSequences), never transformed.
//
// Retrograde is read from the sign of a small centered finite difference in longitude (no
// dependency on a separate per-body motion table), same self-contained-and-verifiable spirit
// as the rest of this project's engines. Ascendant and the luminaries are never
// retrograde-shifted (an angle can't station; Sun/Moon geocentric never appear retrograde) —
// matches the reference script exactly.
//
// SPEED (July 18): the finite difference that reads direction now also keeps its magnitude.
// Every node carries `speed` (deg/day, signed), `speedRatio` (speed ÷ the body's mean motion
// — normalized, so a fast Saturn and a fast Mercury compare), and `isStationary` (<10% of
// mean). These are EXPRESSION LEVELS, not genes: the sequence encoding is untouched BY THEM.
// (Step F did move it: see SEQ_CODEC.)
//
// EXTRAS (July 18, step-3 rebase): the decode surface now expresses the instrument's whole
// display set — SNode/Chiron/Lilith/Ceres/Pallas/Juno/Vesta and the angle family
// (MC/IC/DSC/Vertex/Fortune, with sect) — under `.extras`, full-precision, never sequenced.
// The genome stays 12 genes; the expression is total.
//
// Data engine only. No UI, no zodiacal-releasing logic, no wiring into
// Orbo Astrolabe.dc.html in this pass — a deliberate boundary, not an oversight.

// The Ring is the floor and imports nothing, so depending on it adds no cycle. Angles only:
// the orbs below are the caller's, by law, and stay here. fineStateOf is the gene's own encoder and
// stateOfFine is the projection every cache key is cut at.
// The Mater is the Ring's sibling: the inherent MEANING of the twelve signs, stamped once and
// imported rather than copied. The names, the elements, the traditional rulership and the whole-sign
// house rotation used to be typed out below; SIGN_RULERS was keyed by name here and by index in
// framing.js, which is two chances to be wrong about the same twelve facts.
// The twelve whole-sign frames are the TYMPAN's, not the Mater's (the Connectome pass moved them).


// Traditional (pre-modern) rulerships, name-keyed: Mars/Scorpio, Saturn/Aquarius, matching the
// reference script exactly, not the modern Mars/Pluto, Saturn/Uranus, Jupiter/Neptune set.
const SIGN_RULERS = DOMICILE;

// THE 12-NODE STRUCTURE, IN ORDER (reordered in rewire step F, 2026-08-04). The Ascendant leads:
// it is the one gene that is not a body but a PLACE AND A MOMENT, so it is the chart's own address,
// and the Moon precedes the Sun because the instrument reads the Moon first. `sequence` is
// positional, so this reorder changes every sequence string, which is why it rides with the gene
// change and the two cache keys rather than on its own.
//
// THE 12TH GENE IS THE MEAN NODE (ruled 2026-08-04). The genome holds values from which others
// derive, which is why there is no south-node gene: mean south is mean north plus 180. The mean node
// is a smooth secular function of time and uniformly retrograde, so it is the steadier identity
// value, and it is the better fit for how these positions are generated. The osculating TRUE node
// rides the decode surface as `extras.bodies.Node`, which is the key the instrument has always drawn
// from and the key every flattened map ends up holding, so THE INSTRUMENT DOES NOT MOVE. Both are
// therefore available and the reader chooses; no value is lost. (This is not a sun/moon-law question:
// the genome is neither the instrument nor the pane.) The gene KEY stays `Node` — it is the north-node
// gene — and GENE_SOURCE, plus a `source` field on the record, says what it reads.
const NODE_ORDER = ['Ascendant', 'Moon', 'Sun', 'Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune', 'Pluto', 'Node'];
const PRIMARY_NODES = ['Ascendant', 'Moon', 'Sun']; // reordered to match, so "the first three" stays true positionally
// Which ephemeris quantity a GENE's longitude is read FROM, where the two differ. Genes only: the
// extras below keep their own names, and that is the whole of the fix for what step F first got wrong.
//
// THE FLATTENED DECODE SURFACE KEEPS THE INSTRUMENT'S VOCABULARY. Three readers flatten a genome into
// one longitude map (the DC twice, timespine.natalFromDna) and every one of them
// writes the genes first and `extras.bodies` second. So `Node` in extras is the OSCULATING node the
// instrument has always drawn, it overwrites gene 12 in every flattened map, and the natal glyph on
// the plate does not move by 1.3 degrees because the genome changed its mind about which node is the
// identity value. The gene keeps the MEAN node inside `nodes.Node` (marked by its own `source`
// field), the drawn value stays `extras.bodies.Node`, and both are therefore available.
// (It was FOUR readers until the Connectome pass deleted `rulers.lonsFromDna`, 2026-08-05. This
// sentence went on naming it for a day, which is the defect class this codebase treats as real: a
// record of a deletion is not the deletion undone, and a header nobody re-reads is where a deleted
// reader goes on living. tests/rewire-parity.test.html greps the tree for the name now, so the next
// one cannot outlive its file.)
const GENE_SOURCE = { Node: 'NodeMean' };
// The genome's own codec version. Stamped on anything persisted, never inferred from the digits.
// 1 = one-based 1-720, Sun-first, true node. 2 = Ring states 0-719, Ascendant-first, mean node.
// 3 = Ring FINE states, arcseconds of the circle, 0-2591999. Same order, same node set, same mean
// node; only the resolution moved, and the codec 2 value is recoverable from it by projection.
const SEQ_CODEC = 3;
const RETROGRADE_CAPABLE = ['Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune', 'Pluto', 'Node'];

// ── THE HERMETIC LOTS · ONE FORMULA, ONE PLACE (2026-08-05) ─────────────────────────────────
// The eight at parity, in the ZR chronology's own order. Day formula given; night is the two
// operands reversed. Death takes the WHOLE-SIGN 8th cusp (the asc's own sign start + 210), never
// a quadrant cusp, which is the whole-sign law the houses are read under everywhere else.
//
// IT LIVES HERE, NOT IN EPHEM. A lot takes no jd and no place: it is an arc measured between
// degrees that are already decoded, so it is an EXPRESSION of a moment and not a reading of the
// sky. ephem is the generator; astrodna is what the genome says. (Corollary worth stating: a lot
// needs no horizon of its own, only an asc and a sect, which is why a composite can carry lots
// without the invented place the no-Davison ruling forbids.)
//
// This is the app's only lot arithmetic. zr.computeLots reads a genome and delegates here;
// `extras.lots` below expresses all eight off the same decode; ephem.partOfFortune stays as
// Fortune's own leaf and agrees by construction, asserted in tests/lots.test.html.
const LOTS = ['Fortune', 'Spirit', 'Eros', 'Necessity', 'Courage', 'Victory', 'Nemesis', 'Death'];
function lots(ascLon, isDay, pos) {
  const rev = (a, b) => (isDay ? norm360(ascLon + a - b) : norm360(ascLon + b - a));
  const h8 = norm360(Math.floor(norm360(ascLon) / 30) * 30 + 210);
  const Fortune = rev(pos.Moon, pos.Sun);
  const Spirit = rev(pos.Sun, pos.Moon);
  return {
    Fortune, Spirit,
    Eros: rev(pos.Venus, Spirit),
    Necessity: rev(Fortune, pos.Mercury),
    Courage: rev(Fortune, pos.Mars),
    Victory: rev(pos.Jupiter, Spirit),
    Nemesis: rev(Fortune, pos.Saturn),
    Death: rev(h8, pos.Moon),
  };
}

// Weights for the elemental-balance tally — primary nodes count 3x, classical secondaries 1x,
// outer/node bodies 0.5x — matching the reference script's weighting exactly.
const ELEMENT_WEIGHT = { Sun: 3, Moon: 3, Ascendant: 3, Mercury: 1, Venus: 1, Mars: 1, Jupiter: 1, Saturn: 1, Uranus: 0.5, Neptune: 0.5, Pluto: 0.5, Node: 0.5 };

// Mean daily motion (deg/day) — the normalizer for speedRatio. Ascendant is an angle, no
// orbital speed. Rough long-term means; only the RATIO's scale matters, not 4th decimals.
const MEAN_SPEED = { Sun: 0.9856, Moon: 13.176, Mercury: 1.383, Venus: 1.2, Mars: 0.524, Jupiter: 0.0831, Saturn: 0.0335, Uranus: 0.0117, Neptune: 0.006, Pluto: 0.004, Node: 0.053, SNode: 0.053, Chiron: 0.02, Lilith: 0.111, Ceres: 0.214, Pallas: 0.214, Juno: 0.226, Vesta: 0.272 };
// Bodies that ride the decode surface but NOT the sequence — the genome stays 12 genes. `Node` here is
// the osculating node the instrument draws, and it is deliberately the same KEY the gene uses: every
// flattened map writes extras last, so the instrument's node is the true one and nothing downstream
// gained a body it was never scoped for.
const EXTRA_BODIES = ['Node', 'SNode', 'Chiron', 'Lilith', 'Ceres', 'Pallas', 'Juno', 'Vesta'];

// THE FIVE MAJORS, ADMITTED FROM THE RING (rewire step B, 2026-08-03). The words and the ORBS are
// unchanged: an orb is the caller's, by law, and the Ring holds none. What moved is the KEY SET.
// This table deliberately carries five of the Ring's eleven marks, so the narrowing is DECLARED and
// CHECKED rather than left as a coincidence: a member of ADMITS that is not a mark, or a mark with
// no word or no orb, throws AT LOAD rather than yielding undefined at the moment a reader is reading.
// Marks deliberately NOT carried here: 30 · 45 · 72 · 135 · 144 · 150. Widening this list is a
// doctrine change, not a tidy-up. Verified zero-delta on the fixture in tests/rewire-parity.test.html.
const ASPECT_ADMITS = [0, 60, 90, 120, 180];
const ASPECT_WORD = { 0: 'conjunction', 60: 'sextile', 90: 'square', 120: 'trine', 180: 'opposition' };
const ASPECT_ORB = { 0: 7, 60: 4, 90: 5, 120: 5, 180: 7 };
const ASPECT_DEFS = Object.freeze(ASPECT_ADMITS.map((angle) => {
  if (!MARKS.includes(angle)) throw new Error('astrodna: ' + angle + ' is not a Ring mark');
  const name = ASPECT_WORD[angle], orb = ASPECT_ORB[angle];
  if (!name) throw new Error('astrodna: no word for admitted mark ' + angle);
  if (!(orb > 0)) throw new Error('astrodna: no orb for admitted mark ' + angle);
  return Object.freeze({ angle, name, orb });
}));

function signOf(lonDeg) {
  const L = norm360(lonDeg);
  const idx = Math.floor(L / 30);
  return { idx, name: SIGNS[idx], deg: L - idx * 30 };
}

// THE GENE IS A RING FINE STATE. There is no local encoder any more, and there never will be one:
// step F retired encodeValue in favour of ring.stateOf, and the arcsecond widening is the same door
// one scale down. fineStateOf refuses a non-boolean motion flag, which is why isRetro below is always
// a real boolean, and it refuses a non-finite longitude rather than fabricating 0 Aries.
const SIGN_ARCSEC = 30 * ARCSEC;

// Motion via centered finite difference, ±6 hours — fine enough to resolve direction
// cleanly without being fooled by noise near a station (stations last weeks, not hours).
// One positions() call per side now serves EVERY body (was one pair per node): identical
// math — wrap180(b−a) has the same sign as before — so sequences are bit-stable.
const MOTION_H = 0.25; // days
function speedFrom(posM, posP, name) { // deg/day, signed; negative = retrograde
  if (posM[name] == null || posP[name] == null) return null;
  return wrap180(posP[name] - posM[name]) / (2 * MOTION_H);
}

// whole-sign, 1..12: a LOOKUP into the Mater's stamped frame, not a rotation per call.
function houseOf(signIdx, ascSignIdx) {
  return houseOfSign(signIdx, ascSignIdx);
}

function calcAspects(longitudes) {
  const keys = Object.keys(longitudes);
  const out = [];
  for (let i = 0; i < keys.length; i++) {
    for (let j = i + 1; j < keys.length; j++) {
      const a = keys[i], b = keys[j];
      // The arc is the Ring's, not a local min() of two norm360s — same value to 8.3e-14 over
      // 49,623 pairs, one owner instead of two.
      const dist = arcOf(separation(longitudes[a], longitudes[b]));
      // SINGLE-VALUED: the min residual over the ADMITTED five, one row per pair. The old loop
      // emitted every match, and on the fixture natal no pair ever held two rows and no row's
      // nearest mark differed, so this is zero delta and it matches the Ring's totality claim.
      // Min-residual over the admitted set rather than ring.nearest(), which would answer for the
      // six marks this reader does not carry.
      let best = null;
      for (const def of ASPECT_DEFS) {
        const orb = Math.abs(dist - def.angle);
        if (orb <= def.orb && (!best || orb < best.orb)) best = { nodes: [a, b], aspect: def.name, angle: def.angle, orb };
      }
      if (best) out.push(best);
    }
  }
  return out;
}

// Two families, mirroring the reference script: sign-based (3+ nodes sharing a sign) and
// degree-cluster (3+ nodes within 10 degrees of a given node, scanned forward from each name —
// a deliberately simple pass, matching the source script rather than a full connected-component
// clustering; can report overlapping clusters, which is fine for a "where's this chart dense"
// reading, not meant to be a partition).
function detectStelliums(nodeRecords) {
  const stelliums = [];
  const bySign = {};
  for (const [name, rec] of Object.entries(nodeRecords)) (bySign[rec.sign] ||= []).push(name);
  for (const [sign, names] of Object.entries(bySign)) {
    if (names.length >= 3) stelliums.push({ type: 'sign', sign, nodes: names, element: SIGN_ELEMENTS[sign] });
  }
  const names = Object.keys(nodeRecords);
  for (let i = 0; i < names.length; i++) {
    const cluster = [names[i]];
    const lonA = nodeRecords[names[i]].longitude;
    for (let j = i + 1; j < names.length; j++) {
      const lonB = nodeRecords[names[j]].longitude;
      const dist = Math.min(norm360(lonB - lonA), norm360(lonA - lonB));
      if (dist <= 10) cluster.push(names[j]);
    }
    if (cluster.length >= 3) {
      const sign = nodeRecords[cluster[0]].sign;
      stelliums.push({ type: 'degree-cluster', sign, nodes: cluster, element: SIGN_ELEMENTS[sign] });
    }
  }
  return stelliums;
}

function elementalBalance(nodeRecords) {
  const elements = { fire: 0, earth: 0, air: 0, water: 0 };
  for (const [name, rec] of Object.entries(nodeRecords)) elements[rec.element] += (ELEMENT_WEIGHT[name] ?? 1);
  const dominant = Object.entries(elements).sort((a, b) => b[1] - a[1])[0][0];
  return { ...elements, dominant };
}

function chartRuler(nodeRecords, aspects) {
  const ascSign = nodeRecords.Ascendant.sign;
  const rulerPlanet = SIGN_RULERS[ascSign];
  const rulerAspects = aspects.filter((a) => a.nodes.includes(rulerPlanet));
  return { rulerPlanet, rulerNode: nodeRecords[rulerPlanet] || null, rulerAspects };
}

// The one entry point: build the full AstroDNA sequence for a natal moment/place.
// Returns { jd, lat, lon, nodes, primaryNodes, secondaryNodes, sequence, aspects,
//           stelliums, elemental, ruler }.
// `nodes` is the full-precision decode surface everything downstream should read from;
// `sequence` is the compact arcsecond genome and `degreeSequence` its whole-degree projection.
function buildAstroDNA(jdUT, lat, lon) {
  const pos = positions(jdUT);
  const ang = angles(jdUT, lat, lon);
  const ascSignIdx = Math.floor(norm360(ang.asc) / 30);
  const posM = positions(jdUT - MOTION_H), posP = positions(jdUT + MOTION_H);

  // The 12th gene is the mean node, so its absence is a build error and not a missing decoration.
  if (pos.NodeMean == null) throw new Error('astrodna: the 12th gene is the MEAN node and the ephemeris gave none');

  const nodeRecords = {};
  for (const name of NODE_ORDER) {
    const src = GENE_SOURCE[name] || name;
    const lonDeg = name === 'Ascendant' ? ang.asc : pos[src];
    const s = signOf(lonDeg);
    const speed = name === 'Ascendant' ? null : speedFrom(posM, posP, src);
    // retro stays gated by RETROGRADE_CAPABLE (reference-script law: Sun/Moon/Asc never
    // shift into the 361-720 range) even though speed is now recorded for every body.
    const isRetro = RETROGRADE_CAPABLE.includes(name) && speed != null && speed < 0;
    const mean = MEAN_SPEED[name];
    const gene = fineStateOf(norm360(lonDeg), isRetro);
    const inSign = arcsecOf(gene) % SIGN_ARCSEC;
    nodeRecords[name] = {
      longitude: norm360(lonDeg),
      sign: s.name,
      signIndex: s.idx,
      degreeInSign: s.deg,
      house: houseOf(s.idx, ascSignIdx),
      isRetrograde: isRetro,
      element: SIGN_ELEMENTS[s.name],
      numericalValue: gene,
      // DERIVED, both of them, so display and identity can never disagree about one placement. `state`
      // is the codec-2 whole-degree address, for readers that hand a state to the Ring's plate;
      // `dms` is the L1/L2/L3 ladder's own digits, arcseconds WITHIN THE SIGN, cut from the gene
      // rather than re-floored off the float. Neither is stored anywhere: they are projections.
      state: stateOfFine(gene),
      dms: { degree: Math.floor(inSign / ARCSEC), minute: Math.floor(inSign / 60) % 60, second: inSign % 60 },
      // which ephemeris quantity this gene reads, where it is not simply the gene's own name. The
      // 12th gene says 'NodeMean' out loud, so a reader can never mistake it for the drawn node.
      source: src,
      // expression levels, not genes — never encoded into the sequence:
      speed,
      speedRatio: speed != null && mean ? speed / mean : null,
      isStationary: speed != null && mean ? Math.abs(speed) < 0.1 * mean : false,
    };
  }

  const longitudes = {};
  for (const name of NODE_ORDER) longitudes[name] = nodeRecords[name].longitude;

  const aspects = calcAspects(longitudes);
  const stelliums = detectStelliums(nodeRecords);
  const elemental = elementalBalance(nodeRecords);
  const ruler = chartRuler(nodeRecords, aspects);

  const primaryNodes = {}, secondaryNodes = {}, sequence = [], degreeSequence = [];
  for (const name of NODE_ORDER) {
    const v = nodeRecords[name].numericalValue;
    sequence.push(v);
    degreeSequence.push(nodeRecords[name].state);
    if (PRIMARY_NODES.includes(name)) primaryNodes[name] = v; else secondaryNodes[name] = v;
  }

  // ── extras — the instrument's remaining display set, expressed from the same moment
  // so every engine decodes from ONE surface. Full-precision; never enters the sequence.
  const bodies = {};
  for (const name of EXTRA_BODIES) {
    if (pos[name] == null) continue;
    const s = signOf(pos[name]);
    const speed = speedFrom(posM, posP, name);
    const mean = MEAN_SPEED[name];
    bodies[name] = {
      longitude: norm360(pos[name]), sign: s.name, signIndex: s.idx, degreeInSign: s.deg,
      element: SIGN_ELEMENTS[s.name], house: houseOf(s.idx, ascSignIdx),
      speed, speedRatio: speed != null && mean ? speed / mean : null,
      isRetrograde: speed != null && speed < 0,
    };
  }
  const isDay = norm360(pos.Sun - ang.asc) >= 180; // same sect formula as the instrument
  const lotSet = lots(ang.asc, isDay, pos);
  const extras = {
    bodies,
    angles: {
      asc: norm360(ang.asc), mc: norm360(ang.mc), ic: norm360(ang.mc + 180), dsc: norm360(ang.asc + 180),
      vertex: typeof vertex === 'function' ? norm360(vertex(jdUT, lat, lon)) : null,
      // Fortune stays on `angles` because four readers already flatten it from there. It is not a
      // second computation: it is the lot set's own Fortune, so the two can no longer drift.
      fortune: lotSet.Fortune,
      isDay,
    },
    // THE EIGHT LOTS. Not under `angles`: a lot is not an angle, it is an arc measured from one.
    lots: lotSet,
  };

  return { jd: jdUT, lat, lon, nodes: nodeRecords, primaryNodes, secondaryNodes, sequence, degreeSequence, aspects, stelliums, elemental, ruler, extras };
}

// A stable string identity for the sequence — e.g. for caching/display/comparison —
// deliberately just the compact genome, not the full-precision data.
function sequenceString(dna) {
  return dna.sequence.join('-');
}

// THE PROJECTION, and the one thing a cache key may be cut at. Byte-identical to what
// sequenceString() returned under codec 2, which is why the arcsecond widening rebuilt no artifact:
// the spine seed and fertKey file under this, because neither a materialized event table nor a
// century-long weave moves for one arcsecond. Never use it as the genome's identity, and never use
// sequenceString() as a key — that inverts the whole point and throws a chart's weave away on a
// float wiggle in the ninth decimal.
function degreeSequenceString(dna) {
  return dna.degreeSequence.join('-');
}

window.__ORBO_ASTRODNA = {
  SIGNS, SIGN_ELEMENTS, SIGN_RULERS, NODE_ORDER, PRIMARY_NODES, RETROGRADE_CAPABLE, SEQ_CODEC, LOTS, lots,
  buildAstroDNA, sequenceString, degreeSequenceString,
};
})();
