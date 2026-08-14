// electional.browser.js — auto-generated browser-global build of electional.js (no ES modules; assigns window.__ORBO_ELECTIONAL).
// Source of truth is electional.js — regenerate this file if electional.js changes, don't hand-edit.
// Load order: after framing.browser.js.
(function boot(){
// electional.js — classical electional scoring on the live composite frame.
// Implements the July-2026 comprehensive spec (condition engine, Moon module w/
// outcome aspect, sect-weighted aspect grading, actor significator, Lots, fixed
// stars, and the Field-Theory layer) on top of framing.js's composite mechanics.
if(!window.__ORBO_FRAMING){return void setTimeout(boot,0);}
const {
  SIGNS, RULERS, GLYPHS, LOTS, lots, ASPECTS,
  signIndex, degInSign, midpoint, houseOf, dignityOf,
  norm360, wrap180, positions, angles, BODIES,
} = window.__ORBO_FRAMING;

// ---------------------------------------------------------------------------
// 0. constants — sect, benefics/malefics, dignity tables
// ---------------------------------------------------------------------------
const BENEFICS = ['Venus', 'Jupiter'];
const MALEFICS = ['Mars', 'Saturn'];
const CLASSICAL = ['Sun', 'Moon', 'Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn'];

// element by sign index (0 Aries…): fire=0 earth=1 air=2 water=3
const ELEMENT = i => i % 4;
// Lilly triplicity rulers [day, night] by element
const TRIPLICITY = [
  ['Sun', 'Jupiter'],   // fire
  ['Venus', 'Moon'],    // earth
  ['Saturn', 'Mercury'],// air
  ['Mars', 'Mars'],     // water
];
const EXALT = { Sun: 0, Moon: 1, Mercury: 5, Venus: 11, Mars: 9, Jupiter: 3, Saturn: 6 };

// Egyptian bounds/terms: per sign, [ruler, upToDegree]
const BOUNDS = [
  [['Jupiter',6],['Venus',12],['Mercury',20],['Mars',25],['Saturn',30]],       // Aries
  [['Venus',8],['Mercury',14],['Jupiter',22],['Saturn',27],['Mars',30]],       // Taurus
  [['Mercury',6],['Jupiter',12],['Venus',17],['Mars',24],['Saturn',30]],       // Gemini
  [['Mars',7],['Venus',13],['Mercury',19],['Jupiter',26],['Saturn',30]],       // Cancer
  [['Jupiter',6],['Venus',11],['Saturn',18],['Mercury',24],['Mars',30]],       // Leo
  [['Mercury',7],['Venus',17],['Jupiter',21],['Mars',28],['Saturn',30]],       // Virgo
  [['Saturn',6],['Mercury',14],['Jupiter',21],['Venus',28],['Mars',30]],       // Libra
  [['Mars',7],['Venus',11],['Mercury',19],['Jupiter',24],['Saturn',30]],       // Scorpio
  [['Jupiter',12],['Venus',17],['Mercury',21],['Saturn',26],['Mars',30]],      // Sagittarius
  [['Mercury',7],['Jupiter',14],['Venus',22],['Saturn',26],['Mars',30]],       // Capricorn
  [['Mercury',7],['Venus',13],['Jupiter',20],['Mars',25],['Saturn',30]],       // Aquarius
  [['Venus',12],['Jupiter',16],['Mercury',19],['Mars',28],['Saturn',30]],      // Pisces
];
// Chaldean decans (faces): per sign, three rulers
const FACES = [
  ['Mars','Sun','Venus'],['Mercury','Moon','Saturn'],['Jupiter','Mars','Sun'],
  ['Venus','Mercury','Moon'],['Saturn','Jupiter','Mars'],['Sun','Venus','Mercury'],
  ['Moon','Saturn','Jupiter'],['Mars','Sun','Venus'],['Mercury','Moon','Saturn'],
  ['Jupiter','Mars','Sun'],['Venus','Mercury','Moon'],['Saturn','Jupiter','Mars'],
];

function boundRuler(sign, deg) { for (const [r, up] of BOUNDS[sign]) if (deg < up) return r; return BOUNDS[sign][4][0]; }
function faceRuler(sign, deg) { return FACES[sign][Math.min(2, Math.floor(deg / 10))]; }

// benefic/malefic weight given the chart sect (isDay). Of-sect benefic strongest,
// contrary-sect malefic worst. Spec §1.2.
function sectWeight(body, isDay) {
  if (body === 'Venus') return isDay ? 1.0 : 1.4;       // Venus benefic of the night
  if (body === 'Jupiter') return isDay ? 1.4 : 1.0;     // Jupiter benefic of the day
  if (body === 'Saturn') return isDay ? -1.0 : -1.4;    // Saturn malefic contrary at night
  if (body === 'Mars') return isDay ? -1.4 : -1.0;      // Mars malefic contrary by day
  if (body === 'Sun') return 0.4; if (body === 'Moon') return 0.4;
  return 0.5; // Mercury / outers: neutral-ish carrier
}

// ---------------------------------------------------------------------------
// 1. essential dignity (Lilly points) — spec §2a
// ---------------------------------------------------------------------------
function essentialDignity(body, lon, isDay) {
  const sign = signIndex(lon), deg = degInSign(lon);
  const notes = []; let pts = 0; let dignified = false;
  if (RULERS[sign] === body) { pts += 5; notes.push('domicile'); dignified = true; }
  if (EXALT[body] === sign) { pts += 4; notes.push('exaltation'); dignified = true; }
  if (TRIPLICITY[ELEMENT(sign)][isDay ? 0 : 1] === body) { pts += 3; notes.push('triplicity'); dignified = true; }
  if (boundRuler(sign, deg) === body) { pts += 2; notes.push('bound'); dignified = true; }
  if (faceRuler(sign, deg) === body) { pts += 1; notes.push('face'); dignified = true; }
  // detriment / fall
  if (RULERS[(sign + 6) % 12] === body) { pts -= 5; notes.push('detriment'); }
  if (EXALT[body] != null && (EXALT[body] + 6) % 12 === sign) { pts -= 4; notes.push('fall'); }
  if (!dignified && !notes.length) { pts -= 5; notes.push('peregrine'); }
  return { pts, notes };
}

// ---------------------------------------------------------------------------
// 2. condition engine — essential + accidental. spec §2
// ctx: { comp, compSpd, house(body)->1..12, sunLon (composite), isDay }
// ---------------------------------------------------------------------------
function combustState(lon, sunLon) {
  const d = Math.abs(wrap180(lon - sunLon));
  if (d < 0.28) return 'cazimi';       // within ~17'
  if (d < 8.5) return 'combust';
  if (d < 15) return 'under-beams';
  return 'free';
}

function condition(body, ctx) {
  const lon = ctx.comp[body];
  const ed = essentialDignity(body, lon, ctx.isDay);
  let acc = 0; const drivers = [];
  const push = (v, t) => { acc += v; drivers.push({ v, t }); };
  // house (accidental) — spec §2b
  const h = ctx.house(body);
  const houseScore = { 1: 5, 10: 5, 7: 4, 4: 4, 11: 4, 2: 3, 5: 3, 9: 2, 3: 1, 12: -5, 6: -2, 8: -2 }[h] || 0;
  if (houseScore) push(houseScore, `H${h}`);
  // motion (composite/displayed speed carries natal Rx — spec §12)
  const spd = ctx.compSpd ? ctx.compSpd[body] : 0;
  if (body !== 'Sun' && body !== 'Moon') {
    if (spd < 0) push(-5, 'retrograde');
    else push(2, 'direct');
  }
  // Moon light
  if (body === 'Moon') push(ctx.moonWaxing ? 2 : -2, ctx.moonWaxing ? 'increasing light' : 'decreasing light');
  // combustion (spec §1.3, §9 in-frame: composite Sun)
  if (body !== 'Sun') {
    const cs = combustState(lon, ctx.sunLon);
    if (cs === 'cazimi') push(5, 'cazimi');
    else if (cs === 'combust') push(-5, 'combust');
    else if (cs === 'under-beams') push(-4, 'under the beams');
    else push(1, 'free of the beams');
  }
  const essential = ed.pts;
  return { score: essential + acc, essential, accidental: acc, dignities: ed.notes, drivers };
}

// ---------------------------------------------------------------------------
// 3. aspect grading — spec §6
// ---------------------------------------------------------------------------
const HARMONY = { 0: 0, 60: 1, 90: -1, 120: 1, 180: -1 };
function gradeAspect(bodyA, bodyB, lonA, lonB, orbMax, ctx, applying) {
  const d = Math.abs(wrap180(lonA - lonB));
  let asp = null;
  for (const a of ASPECTS) { const o = Math.abs(d - a.angle); if (o <= orbMax && (!asp || o < asp.orb)) asp = { ...a, orb: o }; }
  if (!asp) return null;
  if (applying === false) return { asp, score: 0, sep: true }; // separating scores ~0
  // conjunction harmony = nature of the more-benefic of the two bodies
  let harmony = HARMONY[asp.angle];
  if (asp.angle === 0) {
    const w = sectWeight(bodyB, ctx.isDay);
    harmony = w >= 0 ? 1 : -1;
  }
  // combustion override for a conjunction to the Sun
  if (asp.angle === 0 && (bodyA === 'Sun' || bodyB === 'Sun')) {
    const other = bodyA === 'Sun' ? bodyB : bodyA;
    const cs = combustState(ctx.comp[other], ctx.sunLon);
    if (cs === 'cazimi') harmony = 1.4; else if (cs !== 'free') harmony = -1;
  }
  const target = Math.abs(sectWeight(bodyB, ctx.isDay));
  const tight = 1 - asp.orb / orbMax;
  return { asp, score: harmony * target * tight, harmony, target };
}

// ---------------------------------------------------------------------------
// 4. Moon module — spec §4
// ---------------------------------------------------------------------------
const VIA_COMBUSTA = lon => { const s = norm360(lon); return s >= 195 && s <= 225; }; // 15° Lib–15° Sco
const VOC_EXEMPT_SIGNS = [3, 1, 8, 11]; // Cancer, Taurus, Sagittarius, Pisces

// next aspect the composite Moon perfects after jd. posAt: jd->positions.
// Uses film speed (natal fixed, moment scrubs) — the classical payoff, spec §4b.
function nextMoonAspect(natal, jd, posAt, opts = {}) {
  const horizon = opts.horizon ?? 2.2, step = opts.step ?? 0.02;
  const compAt = (t, b) => midpoint(natal.pos[b], posAt(t)[b]);
  const targets = ['Sun', 'Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn'];
  let prev = {};
  const diffTo = (t, b) => { const dd = Math.abs(wrap180(compAt(t, 'Moon') - compAt(t, b))); return dd; };
  for (const b of targets) prev[b] = diffTo(jd, b);
  for (let t = jd + step; t <= jd + horizon; t += step) {
    for (const b of targets) {
      const now = diffTo(t, b);
      for (const a of ASPECTS) {
        const pO = prev[b] - a.angle, nO = now - a.angle;
        if (pO === 0 || (pO < 0) !== (nO < 0)) { // crossed partile
          const isDay = natal.isDay;
          const harmony = a.angle === 0 ? (sectWeight(b, isDay) >= 0 ? 1 : -1) : HARMONY[a.angle];
          return { body: b, angle: a.angle, glyph: a.glyph, harmony, weight: sectWeight(b, isDay), jd: t,
            txt: `${GLYPHS.Moon} Moon ${a.glyph} ${GLYPHS[b]} ${b}` };
        }
      }
      prev[b] = now;
    }
  }
  return null;
}

// vocDef: 'lilly' (no perfected aspect before leaving sign) or 'hellenistic' (not
// applying within 30° to any planet; never void in Cnc/Tau/Sag/Pis). spec §4a
function moonModule(natal, ctx, jd, posAt, opts = {}) {
  const vocDef = opts.vocDef || 'hellenistic';
  const drivers = []; let score = 0; let veto = null;
  const push = (v, t, k) => { score += v; drivers.push({ v, t, kind: k || 'moon' }); };
  const mLon = ctx.comp.Moon, mSign = signIndex(mLon);

  // via combusta
  if (VIA_COMBUSTA(mLon)) push(-1.2, 'Moon in via combusta (15° Lib–15° Sco)', 'voc');
  // fall / detriment (mitigated by reception)
  const md = dignityOf('Moon', mSign);
  if (md === 'fall' || md === 'detriment') {
    const recd = ctx.reception && ctx.reception('Moon');
    push(recd ? -0.4 : -1.0, `Moon in ${md}${recd ? ' (received — softened)' : ''}`, 'dignity');
  }
  // Moon exactly on the composite Ascendant
  if (ctx.ascLon != null && Math.abs(wrap180(mLon - ctx.ascLon)) < 3) push(-0.8, 'Moon on the Ascendant', 'moon');
  // post-syzygy: within 12° after New or Full
  const elong = norm360(mLon - ctx.sunLon);
  if (elong < 12 || Math.abs(elong - 180) < 12) push(-0.7, 'Moon still in the shadow of the last syzygy', 'moon');

  // applying hard aspect to a malefic (scaled by target/sect)
  const outcome = opts.outcome !== undefined ? opts.outcome : nextMoonAspect(natal, jd, posAt);
  if (outcome) {
    const w = Math.abs(outcome.weight);
    const val = outcome.harmony >= 0 ? 1.1 * w : -1.1 * w;
    push(val, `outcome: ${outcome.txt} — ${outcome.harmony >= 0 ? 'the venture resolves well' : 'it meets friction'}`, 'outcome');
  }

  // void of course
  let voidMoon = false;
  if (vocDef === 'lilly') {
    // perfects no aspect before leaving its sign
    const degLeft = 30 - degInSign(mLon);
    const na = outcome && (outcome.jd - jd) * ctx.moonFilmSpd < degLeft; // rough
    voidMoon = !na;
  } else {
    voidMoon = !outcome && !VOC_EXEMPT_SIGNS.includes(mSign);
  }
  if (voidMoon) {
    if (opts.initiating) push(-0.9, 'void-of-course Moon — nothing to carry the venture', 'voc');
    else push(0.3, 'void-of-course Moon — the field is at rest', 'voc');
  }
  return { score, drivers, voidMoon, outcome };
}

// ---------------------------------------------------------------------------
// 5. topical dictionary — spec §7. extends framing PROFILES with rising signs +
// avoid sets. keyed by the same profile ids used across the app.
// ---------------------------------------------------------------------------
const TOPICS = {
  text:     { sig: 'Mercury', house: [3], rising: ['Gemini', 'Virgo'], avoid: { retro: ['Mercury'], combust: ['Mercury'] } },
  date:     { sig: 'Venus', house: [5, 7], rising: ['Libra', 'Taurus'], avoid: { retro: ['Venus'], combust: ['Venus'], hard: [['Venus', 'Saturn'], ['Venus', 'Pluto']] } },
  hard:     { sig: 'Mercury', house: [3], rising: ['Capricorn', 'Virgo'], avoid: { angleMalefic: ['Mars'], combust: ['Mercury'] } },
  ask:      { sig: 'Jupiter', house: [11, 2, 7, 10], rising: ['Sagittarius', 'Pisces'], avoid: { hard: [['Jupiter', 'Saturn']] } },
  repair:   { sig: 'Venus', house: [4], rising: ['Libra', 'Cancer'], avoid: { retro: ['Venus'] } },
  intimacy: { sig: 'Venus', house: [5, 8], rising: ['Scorpio', 'Taurus'], avoid: { retro: ['Venus', 'Mars'] } },
  business: { sig: 'Jupiter', house: [7, 2, 10], rising: ['Capricorn', 'Virgo'], avoid: { hard: [['Jupiter', 'Saturn']], combust: ['Mercury'] } },
};

// ---------------------------------------------------------------------------
// 6. Lots + fixed stars — spec §8
// ---------------------------------------------------------------------------
function lotBlock(ctx, profileKey) {
  const drivers = []; let score = 0;
  const L = ctx.lots; if (!L) return { score, drivers };
  const angular = lon => [1, 10, 7, 4].includes(ctx.houseAbs(lon));
  const check = (name, key, tag) => {
    const lon = L[key]; if (lon == null) return;
    if (angular(lon)) { score += 0.4; drivers.push({ v: 0.4, t: `${tag} angular — supports it`, kind: 'lot' }); }
    for (const m of MALEFICS) { const o = Math.abs(wrap180(lon - ctx.comp[m])); if (o < 3) { score -= 0.3; drivers.push({ v: -0.3, t: `${GLYPHS[m]} ${m} afflicts ${tag}`, kind: 'lot' }); } }
  };
  check('Fortune', 'Fortune', 'Fortune');
  if (['ask', 'hard', 'business'].includes(profileKey)) check('Spirit', 'Spirit', 'Spirit (Daimon)');
  if (['date', 'intimacy', 'repair'].includes(profileKey)) check('Eros', 'Eros', 'Eros');
  return { score, drivers };
}

const FIXED_STARS = [
  { name: 'Algol', lon: 56, v: -1, note: 'Algol' },        // 26° Taurus
  { name: 'Spica', lon: 204, v: 1, note: 'Spica' },        // 24° Libra
  { name: 'Regulus', lon: 150, v: 1, note: 'Regulus' },    // 0° Virgo
  { name: 'Vindemiatrix', lon: 190, v: -0.6, note: 'Vindemiatrix' }, // 10° Libra
];
function fixedStarBlock(ctx, sigs) {
  const drivers = []; let score = 0;
  const check = (lon, who) => { for (const st of FIXED_STARS) if (Math.abs(wrap180(lon - st.lon)) < 1) { score += st.v; drivers.push({ v: st.v, t: `${who} on ${st.note}`, kind: 'star' }); } };
  for (const b of sigs) check(ctx.comp[b], `${GLYPHS[b]} ${b}`);
  if (ctx.ascLon != null) check(ctx.ascLon, 'the Ascendant');
  return { score, drivers };
}

// ---------------------------------------------------------------------------
// 7. Field-Theory layer — spec §9
// ---------------------------------------------------------------------------
function fieldBlock(natal, ctx, jd, posAt) {
  const drivers = []; let score = 0; let veto = null;
  const cAsc = ctx.ascLon;
  if (cAsc != null) {
    // cASC trine/sextile natal benefics
    for (const b of ['Venus', 'Mercury', 'Jupiter']) {
      const d = Math.abs(wrap180(cAsc - natal.pos[b]));
      if (Math.abs(d - 120) < 2 || Math.abs(d - 60) < 2) { score += 0.3; drivers.push({ v: 0.3, t: `composite ASC harmonizes natal ${GLYPHS[b]} ${b}`, kind: 'field' }); }
    }
    // sect-light window bonus
    const sl = natal.pos[natal.sectLight];
    if (Math.abs(wrap180(cAsc - sl)) < 3) { score += 0.5; drivers.push({ v: 0.5, t: `composite ASC crossing your ${natal.sectLight} — the personal optimum window`, kind: 'field' }); }
    // natal Saturn / via combusta = personal avoid degree
    if (Math.abs(wrap180(cAsc - natal.pos.Saturn)) < 3) { score -= 0.6; drivers.push({ v: -0.6, t: 'composite ASC on natal Saturn — your avoid-degree', kind: 'field' }); }
    if (VIA_COMBUSTA(cAsc)) { score -= 0.4; drivers.push({ v: -0.4, t: 'composite ASC in via combusta', kind: 'field' }); }
  }
  return { score, drivers, veto };
}

// arc-bound impossibility: each composite planet only spans natal ±90° (a 180°
// reachable longitude arc centred on its natal position). if the topical house's
// sign (at the live composite ASC) lies entirely outside that arc, the significator
// structurally cannot occupy it this frame — spec §9.
function arcBound(natal, sig, houses, cAsc) {
  const center = natal.pos[sig];
  const ascSign = signIndex(cAsc);
  const reachable = houses.some(hn => {
    const signStart = ((ascSign + hn - 1) % 12) * 30;
    // nearest point of the house sign's 30° span to the sig's natal longitude
    const dStart = Math.abs(wrap180(signStart - center));
    const dEnd = Math.abs(wrap180(signStart + 30 - center));
    const inside = Math.abs(wrap180((signStart + 15) - center)) < 15; // centre within span
    const nearest = inside ? 0 : Math.min(dStart, dEnd);
    return nearest <= 90;
  });
  return !reachable;
}

// ---------------------------------------------------------------------------
// 8. speed model — spec §12. natal + transit speeds, composite (displayed) and
// film (moment-scrub) speeds. numeric derivatives off the ephemeris.
// ---------------------------------------------------------------------------
function bodySpeed(jd, body, posAt) {
  const h = 0.02;
  return wrap180(posAt(jd + h)[body] - posAt(jd - h)[body]) / (2 * h);
}
function speedModel(natal, jd, posAt) {
  const natalSpd = {}, transitSpd = {}, compSpd = {}, filmSpd = {};
  for (const b of BODIES) {
    if (!natal._spd) natal._spd = {};
    if (natal._spd[b] == null) natal._spd[b] = bodySpeed(natal.jd, b, positions);
    natalSpd[b] = natal._spd[b];
    transitSpd[b] = bodySpeed(jd, b, posAt);
    compSpd[b] = (natalSpd[b] + transitSpd[b]) / 2;   // displayed — carries natal Rx
    filmSpd[b] = transitSpd[b] / 2;                    // moment-scrub position speed
  }
  return { natalSpd, transitSpd, compSpd, filmSpd };
}

// applying/separating/standing between two composite bodies. mode 'frame' uses
// displayed speed; 'film' uses film speed (both natal fixed → same-body standing).
function applyingState(ctx, b1, b2, mode = 'frame') {
  const spd = mode === 'film' ? ctx.filmSpd : ctx.compSpd;
  const rel = (spd[b1] || 0) - (spd[b2] || 0);
  if (Math.abs(rel) < 0.02) return 'standing';
  const sep = wrap180(ctx.comp[b1] - ctx.comp[b2]);
  // separation shrinking → applying
  return (Math.sign(rel) === -Math.sign(sep)) ? 'applying' : 'separating';
}

// two-chart synastry grid — same-body pairs included and prioritized. spec §12.
function gradeSynastry(natal1, natal2, jd, posAt, opts = {}) {
  const mode = opts.mode || 'frame', orbMax = opts.orb ?? 3;
  const compA = {}, compB = {};
  for (const b of BODIES) { compA[b] = midpoint(natal1.pos[b], posAt(jd)[b]); compB[b] = midpoint(natal2.pos[b], posAt(jd)[b]); }
  const smA = speedModel(natal1, jd, posAt), smB = speedModel(natal2, jd, posAt);
  const pairs = [];
  for (const b1 of CLASSICAL) for (const b2 of CLASSICAL) {
    const d = Math.abs(wrap180(compA[b1] - compB[b2]));
    let asp = null; for (const a of ASPECTS) { const o = Math.abs(d - a.angle); if (o <= orbMax && (!asp || o < asp.orb)) asp = { ...a, orb: o }; }
    if (!asp) continue;
    const sameBody = b1 === b2;
    // relative speed by mode
    const s1 = mode === 'film' ? smA.filmSpd[b1] : smA.compSpd[b1];
    const s2 = mode === 'film' ? smB.filmSpd[b2] : smB.compSpd[b2];
    const rel = s1 - s2;
    let state; if (Math.abs(rel) < 0.02) state = 'standing';
    else { const sep = wrap180(compA[b1] - compB[b2]); state = (Math.sign(rel) === -Math.sign(sep)) ? 'applying' : 'separating'; }
    const rec = { b1, b2, asp, sameBody, state, orb: asp.orb,
      lon1: compA[b1], lon2: compB[b2],
      txt: `${GLYPHS[b1]} ${b1} ${asp.glyph} ${GLYPHS[b2]} ${b2}` };
    if (sameBody) { rec.natalGapEstimate = 2 * asp.orb; rec.frozen = (mode === 'film'); } // §12 doubled orb recovers natal gap
    pairs.push(rec);
  }
  pairs.sort((a, b) => (b.sameBody - a.sameBody) || (a.orb - b.orb)); // same-body first
  return pairs;
}

// ---------------------------------------------------------------------------
// 9. aggregation — spec §10
// ---------------------------------------------------------------------------
const WEIGHTS = { moon: 0.30, actor: 0.20, topic: 0.20, angles: 0.12, aspects: 0.10, field: 0.05, lots: 0.02, fixstar: 0.01 };

// ---------------------------------------------------------------------------
// 9a. synchronic composite intersections — a pure LISTER (not a scorer) of the
// inter-chart aspects between two SYNCHRONIC composites: A = midpoint(natA, now),
// B = midpoint(natB, now). Every A-body × B-body major contact in orb, no sect
// weighting. Nodes kept and Node/SNode listed SEPARATELY. Chiron/Lilith excluded
// to match the body set. Exact-time scan + travel live in the app.
// ---------------------------------------------------------------------------
const XBODIES = ['Sun','Moon','Mercury','Venus','Mars','Jupiter','Saturn','Uranus','Neptune','Pluto','Node','SNode'];
const XMAJORS = ASPECTS.filter(a => [0, 60, 90, 120, 180].includes(a.angle));
function crossAspects(natA, natB, jd, posAt, opts = {}) {
  const orb = opts.orb ?? 3;
  const mom = posAt(jd);
  const compA = {}, compB = {};
  for (const b of XBODIES) {
    if (natA.pos[b] != null && mom[b] != null) compA[b] = midpoint(natA.pos[b], mom[b]);
    if (natB.pos[b] != null && mom[b] != null) compB[b] = midpoint(natB.pos[b], mom[b]);
  }
  const out = [];
  for (const ba of XBODIES) for (const bb of XBODIES) {
    if (compA[ba] == null || compB[bb] == null) continue;
    const d = Math.abs(wrap180(compA[ba] - compB[bb]));
    for (const asp of XMAJORS) {
      const o = Math.abs(d - asp.angle);
      if (o <= orb) { out.push({ a: ba, b: bb, angle: asp.angle, name: asp.name, glyph: asp.glyph, orb: o }); break; }
    }
  }
  return out;
}

// ---------------------------------------------------------------------------
// 9b. two-chart synastry timing (partner Timing tab). scores the synastry of two
// live composites at a single moment — sect-weighted, harmony-graded, applying
// only, angle contacts NOT over-boosted. profile = framing PROFILES[key].
// ---------------------------------------------------------------------------
function scoreMomentSynastry(natA, natB, jd, posAt, profile, opts = {}) {
  const orb = opts.orb ?? 3;
  const mom = posAt(jd);
  const compA = {}, compB = {};
  for (const b of BODIES) { compA[b] = midpoint(natA.pos[b], mom[b]); compB[b] = midpoint(natB.pos[b], mom[b]); }
  const isDay = natA.isDay; // election judged from the initiator's sect
  const ctxB = { comp: compB, sunLon: compB.Sun, isDay };
  const ctxA = { comp: compA, sunLon: compA.Sun, isDay };
  const smA = speedModel(natA, jd, posAt), smB = speedModel(natB, jd, posAt);
  const sw = b => profile.sigs.includes(b) ? 1.6 : profile.holders.includes(b) ? 1.15
    : (b === natA.sectLight || b === natB.sectLight) ? 0.6 : (b === 'Sun' || b === 'Moon') ? 0.35 : 0;
  const stateOf = (l1, l2, s1, s2) => {
    const rel = (s1 || 0) - (s2 || 0);
    if (Math.abs(rel) < 0.02) return 'standing';
    return Math.sign(rel) === -Math.sign(wrap180(l1 - l2)) ? 'applying' : 'separating';
  };
  const drivers = []; let score = 0;
  // cross-aspects: A's composite planet × B's composite planet
  for (const ba of CLASSICAL) for (const bb of CLASSICAL) {
    const w = (sw(ba) + sw(bb)) / 2; if (w <= 0) continue;
    const g = gradeAspect(ba, bb, compA[ba], compB[bb], orb, ctxB, true);
    if (!g || !g.asp) continue;
    const state = stateOf(compA[ba], compB[bb], smA.compSpd[ba], smB.compSpd[bb]);
    if (state === 'separating') continue;
    const val = w * g.score * (state === 'standing' ? 0.6 : 1);
    if (Math.abs(val) < 0.02) continue;
    score += val;
    drivers.push({ v: val, a: ba, b: bb, angle: g.asp.angle, orb: g.asp.orb, state, kind: 'aspect',
      txt: `A ${GLYPHS[ba]} ${ba} ${g.asp.glyph} B ${GLYPHS[bb]} ${bb} · ${g.asp.orb.toFixed(1)}° ${state}` });
  }
  // angle contacts: composite planet to the OTHER person's composite ASC/MC.
  // graded by harmony + sect weight of the planet, applying only, no boost.
  const cAscA = midpoint(natA.asc, angles(jd, natA.lat, natA.lon).asc);
  const cMcA = midpoint(natA.mc, angles(jd, natA.lat, natA.lon).mc);
  const cAscB = midpoint(natB.asc, angles(jd, natB.lat, natB.lon).asc);
  const cMcB = midpoint(natB.mc, angles(jd, natB.lat, natB.lon).mc);
  const angleHit = (planet, pLon, pSpd, angLon, angName, side, ctx) => {
    const w = sw(planet); if (w <= 0) return;
    const g = gradeAspect(planet, planet, pLon, angLon, orb, ctx, true);
    if (!g || !g.asp) return;
    // angle moves ~1°/day in longitude terms here; treat planet motion as dominant
    const state = stateOf(pLon, angLon, pSpd, 0);
    if (state === 'separating') return;
    const val = 0.8 * w * (HARMONY[g.asp.angle] || (g.asp.angle === 0 ? 1 : 0)) * (1 - g.asp.orb / orb) * (state === 'standing' ? 0.6 : 1);
    if (Math.abs(val) < 0.02) return;
    score += val;
    drivers.push({ v: val, a: planet, angleContact: true, angle: g.asp.angle, orb: g.asp.orb, state, angName, side,
      kind: 'angle', txt: `${side === 'A' ? 'A' : 'B'} ${GLYPHS[planet]} ${planet} ${g.asp.glyph} ${side === 'A' ? "B's" : "A's"} ${angName} · ${g.asp.orb.toFixed(1)}° ${state}` });
  };
  for (const b of CLASSICAL) {
    angleHit(b, compA[b], smA.compSpd[b], cAscB, 'cASC', 'A', ctxB);
    angleHit(b, compA[b], smA.compSpd[b], cMcB, 'cMC', 'A', ctxB);
    angleHit(b, compB[b], smB.compSpd[b], cAscA, 'cASC', 'B', ctxA);
    angleHit(b, compB[b], smB.compSpd[b], cMcA, 'cMC', 'B', ctxA);
  }
  if (profile.invert) { score = -score * 0.6; drivers.forEach(d => d.v = -d.v * 0.6); }
  // each person's ASC-ruler (actor significator) scored by condition — matches the
  // solo engine's actor term. Not inverted (a strong ruler is favorable regardless).
  const actorBlock = (comp, cAsc, spd, tag) => {
    const sig = RULERS[signIndex(cAsc)];
    const actx = { comp, sunLon: comp.Sun, isDay, compSpd: spd, moonWaxing: norm360(comp.Moon - comp.Sun) < 180, house: b => houseOf(comp[b], cAsc) };
    const c = condition(sig, actx);
    const rel = 0.5 + 0.5 * Math.min(1, sw(sig)); // ASC ruler counts more when it's also a significator
    const val = (c.score / 12) * rel;
    if (Math.abs(val) < 0.02) return;
    score += val;
    drivers.push({ v: val, kind: 'actor', a: sig,
      txt: `${tag} actor ${GLYPHS[sig]} ${sig} (ruler of rising ${SIGNS[signIndex(cAsc)]}): ${c.dignities.join(', ') || 'peregrine'} · cond ${c.score >= 0 ? '+' : ''}${c.score}` });
  };
  actorBlock(compA, cAscA, smA.compSpd, 'A');
  actorBlock(compB, cAscB, smB.compSpd, 'B');
  drivers.sort((a, b) => Math.abs(b.v) - Math.abs(a.v));
  return { score, drivers, jd };
}

// scan a calendar day at `samples` points; return the best moment + its drivers.
// jdLocalMidnight: julianDay(y,mo,d,0,0,0,tz). posAt: jd->positions.
function scoreDayV2(natA, natB, jdLocalMidnight, posAt, profile, opts = {}) {
  const samples = opts.samples ?? 8;
  const stepH = 24 / samples;
  let best = null; const all = [];
  for (let i = 0; i < samples; i++) {
    const jd = jdLocalMidnight + (i * stepH) / 24;
    const r = scoreMomentSynastry(natA, natB, jd, posAt, profile, opts);
    all.push(r);
    if (!best || r.score > best.score) best = r;
  }
  return { score: best.score, bestJd: best.jd, drivers: best.drivers, samples: all };
}

// SOLO multi-day: for one calendar day, find each activity's best intraday window.
// profiles = Object.entries(PROFILES). Returns [{id,label,score,jd,drivers,outcome,veto,cAscSign}].
// The Moon's outcome aspect is activity-independent, so it's computed once per sample.
function scoreDaySolo(natal, jdLocalMidnight, posAt, profiles, opts = {}) {
  const samples = opts.samples ?? 6, orb = opts.orb ?? 3;
  const acts = {};
  for (let i = 0; i < samples; i++) {
    const jd = jdLocalMidnight + (i * 24 / samples) / 24;
    const outcome = nextMoonAspect(natal, jd, posAt, { horizon: 1.3, step: 0.03 });
    for (const [id, p] of profiles) {
      const r = scoreMomentV2(natal, jd, posAt, id, { orb, vocDef: opts.vocDef, initiating: !!p.initiating, outcome });
      if (!acts[id] || r.score > acts[id].score) acts[id] = { id, label: p.label, score: r.score, jd, drivers: r.drivers, outcome: r.outcome, veto: r.veto, cAscSign: r.cAscSign };
    }
  }
  return Object.values(acts);
}


// natal: computeNatal result. posAt: jd->positions. profileKey: PROFILES id.
// opts: { isDay, initiating (from PROFILE), vocDef, outcome (precomputed) }
function scoreMomentV2(natal, jd, posAt, profileKey, opts = {}) {
  const topic = TOPICS[profileKey] || { sig: 'Sun', house: [1], rising: [], avoid: {} };
  const isDay = natal.isDay;
  const mom = posAt(jd);
  const comp = {}; for (const b of BODIES) comp[b] = midpoint(natal.pos[b], mom[b]);
  const ang = angles(jd, natal.lat, natal.lon);
  const cAsc = midpoint(natal.asc, ang.asc);
  const sm = speedModel(natal, jd, posAt);
  const L = lots(cAsc, isDay, comp);
  // Moon phase (waxing = elongation 0–180 increasing)
  const elong = norm360(comp.Moon - comp.Sun);
  const moonWaxing = elong < 180;

  const houseFromCAsc = body => houseOf(comp[body], cAsc);
  const houseAbs = lon => houseOf(lon, cAsc);
  const reception = body => {
    const disp = RULERS[signIndex(comp[body])];
    const back = RULERS[signIndex(comp[disp])] === body;
    const seesRuler = Math.abs(wrap180(comp[body] - comp[disp])) % 60 < 3;
    return back || seesRuler;
  };
  const ctx = {
    comp, compSpd: sm.compSpd, filmSpd: sm.filmSpd, isDay,
    sunLon: comp.Sun, ascLon: cAsc, moonWaxing, lots: L,
    moonFilmSpd: sm.filmSpd.Moon,
    house: houseFromCAsc, houseAbs, reception,
  };

  const allDrivers = [];
  const add = (arr, w, kind) => arr.forEach(d => allDrivers.push({ v: d.v * w, t: d.t, kind: d.kind || kind }));

  // hard veto: arc-bound impossibility
  let veto = null;
  if (arcBound(natal, topic.sig, topic.house, cAsc)) {
    veto = `${GLYPHS[topic.sig]} ${topic.sig} cannot reach the ${topic.house.map(h => 'H' + h).join('/')} in this frame — the election is structurally impossible here.`;
  }

  // §3b Moon module (includes outcome aspect)
  const moon = moonModule(natal, ctx, jd, posAt, { vocDef: opts.vocDef, initiating: opts.initiating, outcome: opts.outcome });
  add(moon.drivers, WEIGHTS.moon);
  if (moon.voidMoon && opts.initiating) veto = veto || null; // penalty already applied, not a hard veto

  // §3a actor significator = ruler of the composite ASC sign
  const actorSig = RULERS[signIndex(cAsc)];
  const actorCond = condition(actorSig, ctx);
  allDrivers.push({ v: (actorCond.score / 12) * WEIGHTS.actor, t: `actor ${GLYPHS[actorSig]} ${actorSig} (ruler of rising ${SIGNS[signIndex(cAsc)]}): ${actorCond.dignities.join(', ') || 'peregrine'} · cond ${actorCond.score >= 0 ? '+' : ''}${actorCond.score}`, kind: 'actor' });
  // preferred rising sign bonus
  if (topic.rising.includes(SIGNS[signIndex(cAsc)])) allDrivers.push({ v: 0.4 * WEIGHTS.actor, t: `${SIGNS[signIndex(cAsc)]} rising — well matched to the matter`, kind: 'actor' });

  // §3c topical significator + house
  const sigCond = condition(topic.sig, ctx);
  allDrivers.push({ v: (sigCond.score / 12) * WEIGHTS.topic, t: `${GLYPHS[topic.sig]} ${topic.sig} (significator): ${sigCond.dignities.join(', ') || 'peregrine'} · cond ${sigCond.score >= 0 ? '+' : ''}${sigCond.score}`, kind: 'topic' });
  if (topic.house.includes(houseFromCAsc(topic.sig))) allDrivers.push({ v: 0.5 * WEIGHTS.topic, t: `${GLYPHS[topic.sig]} ${topic.sig} in its own house (H${houseFromCAsc(topic.sig)})`, kind: 'topic' });

  // §5 benefics/malefics on angles
  const angleDrivers = [];
  for (const b of [...BENEFICS, ...MALEFICS]) {
    const h = houseFromCAsc(b);
    if (h === 1 || h === 10) {
      const w = sectWeight(b, isDay);
      angleDrivers.push({ v: (w >= 0 ? 0.6 : -0.6) * Math.abs(w), t: `${GLYPHS[b]} ${b} on an angle (H${h})${w >= 0 ? ' — bonified' : ' — maltreats the field'}` });
    }
  }
  add(angleDrivers, WEIGHTS.angles, 'angle');

  // §6 graded applying aspects among significators/actor
  const graded = [];
  const focus = [...new Set([topic.sig, actorSig, natal.sectLight, 'Moon'])];
  for (let i = 0; i < focus.length; i++) for (let j = 0; j < BODIES.length; j++) {
    const b1 = focus[i], b2 = BODIES[j]; if (b1 === b2) continue;
    const app = applyingState(ctx, b1, b2, 'frame');
    const g = gradeAspect(b1, b2, comp[b1], comp[b2], opts.orb ?? 3, ctx, app !== 'separating');
    if (g && !g.sep && Math.abs(g.score) > 0.05) graded.push({ v: g.score, t: `${GLYPHS[b1]} ${b1} ${g.asp.glyph} ${GLYPHS[b2]} ${b2} · ${g.asp.orb.toFixed(1)}° ${app}` });
  }
  graded.sort((a, b) => Math.abs(b.v) - Math.abs(a.v));
  add(graded.slice(0, 6), WEIGHTS.aspects, 'aspect');

  // §8 lots + fixed stars
  add(lotBlock(ctx, profileKey).drivers, WEIGHTS.lots, 'lot');
  add(fixedStarBlock(ctx, focus).drivers, WEIGHTS.fixstar, 'star');

  // §9 field layer
  const field = fieldBlock(natal, ctx, jd, posAt);
  add(field.drivers, WEIGHTS.field, 'field');
  if (field.veto) veto = veto || field.veto;

  let score = allDrivers.reduce((s, d) => s + d.v, 0);
  if (veto) score = Math.min(score, -3);
  allDrivers.sort((a, b) => Math.abs(b.v) - Math.abs(a.v));
  return { t: jd, score, veto, outcome: moon.outcome, cAscSign: SIGNS[signIndex(cAsc)], actorSig, drivers: allDrivers };
}


window.__ORBO_ELECTIONAL = { CLASSICAL, sectWeight, essentialDignity, combustState, condition, gradeAspect, nextMoonAspect, moonModule, TOPICS, lotBlock, fixedStarBlock, fieldBlock, arcBound, bodySpeed, speedModel, applyingState, gradeSynastry, crossAspects, WEIGHTS, scoreMomentSynastry, scoreDayV2, scoreDaySolo, scoreMomentV2 };
})();
