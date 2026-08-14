// prism.browser.js — browser-global build of prism.js (registers window.__ORBO_PRISM).
// Source of truth is prism.js. CLAUDE.md's generated-files exception applies: there is no generator
// in this project, so this is a HAND-MAINTAINED literal mirror — a change to prism.js must be
// mirrored here in the same turn and verified by running tests/prism.test.html.
// Load order: after ephem.browser.js, framing.browser.js, ring.browser.js, mater.browser.js, tympan.browser.js and loom.browser.js (P5 · the ledger reuses the one scanner).
(function boot(){
if(!window.__ORBO_EPH||!window.__ORBO_FRAMING||!window.__ORBO_RING||!window.__ORBO_TYMPAN||!window.__ORBO_LOOM){return void setTimeout(boot,0);}
const { norm360, wrap180, arcFor, beadFamily, refract, signIndex, SIGNS, BODIES, LOTS, SYN_CONFIRM, ASPECTS, synOrb } = window.__ORBO_FRAMING;
const { houseOfSign, rulerOfHouse, FLIP_HOUSES } = window.__ORBO_TYMPAN;
const { MARKS, nearest, separation } = window.__ORBO_RING;
const { gmst, obliquity } = window.__ORBO_EPH;
const { scanTargets } = window.__ORBO_LOOM;
// prism.js — Phase 6 · P2 · THE SYNCHRONIC TIMESPINE, FIXED AT ENGRAVE.
//
// The user's framing, which is the right one: the synchronic layer is a whole other timespine that
// should be calculated once and then displayed. §1 is why that is literally true rather than a
// convenience — `sASC = midpoint(nASC, risingDegree)` CONTAINS NO TIME. The map from a rising degree
// to a synchronic Ascendant is a fixed relation of the native's chart, settled the moment the chart is
// engraved; all of the sASC's time-dependence is inherited from the horizon's own rotation. So a
// synchronic day is a FIXED TEMPLATE plus one number (§1.1), and this file is the template.
//
// THE SPLIT THIS FILE EXISTS TO HOLD (§3): the prism's ARITHMETIC stays arithmetic and the prism's
// STRUCTURE becomes tables. A position is one wrap and one halving through framing.refract — cheaper
// to compute than to look up, and a 360-row refraction table per occupant is REFUSED because it would
// quantize to whole degrees against the codec law. What is expensive and constant for a life is the
// structure a live cursor is read THROUGH: which signs a placement can ever occupy, which houses,
// which lord governs each stretch, what order the day walks them in, and which marks a same-body pair
// can ever form. None of that is a position and none of it is an event time.
//
// WHICH IS WHY "the synchronic timespine is calculable at engrave" and "the clock is never a table on
// the spine" are both true, and not in tension. No event times are stored here, ever. Nothing in this
// file is fused. The TimeSpine remains the sole owner of the cursor; this is a lens, not a clock.
//
// NOT STORED, and the two exclusions are different in kind:
//   · CROSS-BODY separations. `sA − sB` retains `(skyA − skyB)/2`, which does not cancel, so a
//     cross-body pair can form any mark. There is no family and no table — only same-body pairs have
//     one, because there the sky term cancels exactly.
//   · LOT ARCS. Ruled 2026-08-06 (§14.2): sect is the synchronic chart's own, from sSun against sASC,
//     so a diurnal native can have a nocturnal synchronic chart, and then Fortune and Spirit exchange
//     formulae and the two ends of a lot's arc come from DIFFERENT equations. There is no single
//     stable arc to store. Lots are computed LIVE from refracted Ascendant, Moon and Sun instead,
//     which is exact under one sect and needs no table. A lot is still an occupant in every other
//     sense; it is its ARC that has no engrave-time value.
// P3 takes exactly two things from the ephemeris and NO position: the earth's rotation (gmst) and its
// tilt (obliquity). The ascension template touches no body, so it is not a reading of the sky and does
// not want the spine's door — it is the geometry of the horizon at a latitude, which is engrave data.

// ---------- codec ----------
// Bumped whenever the SHAPE or the derivation of anything below changes, so a filed table misses and
// rebuilds rather than being read at the wrong shape. Same discipline as connectome.CODEC.
// CODEC 2 (P3): prismKey gained the latitude, because the ascension template is latitude-dependent
// structure and a filed table built at another place must miss rather than be read at the wrong place.
// CODEC 3 (P4): every stop now CARRIES the walk it opens at (`sigma`, `sigmaEnd`). The value was
// computed inside templateOf and thrown away, which is exactly the defect P2's self-test caught with
// `frameOffset`: a value computed and not recorded is invisible to every reader, and the dial is the
// reader that wanted it. A shape change, so filed tables miss and rebuild.
const CODEC = 3;

const LOT_SET = new Set(LOTS);
const SEG_PER_ARC = 6;                    // 180° / 30° — the boundary count inside a full arc
const ARCSEC = 3600;
const SASC_DEG_PER_DAY = 180;             // the horizon does 360, the sASC half of it (§1.1)
const D2R = Math.PI / 180, R2D = 180 / Math.PI;
const J2000 = 2451545;
// The rate gmst advances, degrees per mean solar day, taken from ephem's own polynomial rather than
// retyped as a period: one constant, one owner. Everything about the daily offset falls out of it.
const RAMC_RATE = 360.98564736629;
const SIDEREAL_DAY = 360 / RAMC_RATE;   // 0.99726957 mean solar days — one rotation

function ck(v, who) { if (!Number.isFinite(v)) throw new Error('prism: ' + who + ' needs a finite longitude'); return v; }
function ckSign(v, who) { const i = Math.trunc(v); if (!(i >= 0 && i <= 11)) throw new Error('prism: ' + who + ' needs a sign address 0-11, got ' + v); return i; }

// ---------- 1 · the arc, cut into its segments ----------
// The placement's permitted movement is the 180° arc centred on its natal degree (framing.arcFor: the
// natal degree is the CENTRE, the ends are natal ±90). Six sign boundaries fall inside it, so the arc
// is seven stretches — and each stretch's readings are a permanent fact of the chart, which is the
// part `synchronicTargets` never had. It computes the boundary DEGREES for today's scan; their
// readings and their ORDER are what this stores.
//
// THE AXIS IS STORAGE, NEVER A SECOND PLACEMENT. The two ends of the arc are the limits of where the
// object may go, not two co-present positions with a ruler held in reserve. There is no
// counter-dispositor here and there must never be one.
// The unwrapped cuts of an arc, in real coordinates centred on the natal degree. Shared by the arc
// and the itinerary so the two can never disagree about where a stretch begins — recovering an
// unwrapped start from a normalized one is exactly the kind of second derivation this codebase treats
// as a defect.
function cutsOf(natalLon) {
  const s = natalLon - 90;                                  // real-valued, deliberately unnormalized
  // Exact rather than sampled: the first 30° multiple strictly inside, then every 30° to the far end.
  // A natal degree sitting exactly on a cusp yields FIVE boundaries and six signs, and that is the
  // honest answer for it rather than a seventh segment of zero width.
  const bounds = [];
  for (let b = Math.ceil((s + 1e-9) / 30) * 30; b < s + 180 - 1e-9; b += 30) bounds.push(b);
  return [s, ...bounds, s + 180];
}

function segmentsOf(natalLon, ascSignIdx) {
  ck(natalLon, 'segmentsOf'); const asc = ckSign(ascSignIdx, 'segmentsOf');
  const arc = arcFor(natalLon);
  const cuts = cutsOf(natalLon);
  const segments = [];
  for (let i = 0; i < cuts.length - 1; i++) {
    const lo = cuts[i], hi = cuts[i + 1];
    // The sign is read from the segment's INTERIOR, never an endpoint: an endpoint is a boundary and
    // belongs to two signs by construction.
    const sg = signIndex(norm360((lo + hi) / 2));
    const house = houseOfSign(sg, asc);
    segments.push(Object.freeze({
      index: i,
      startLon: norm360(lo), endLon: norm360(hi),
      spanDeg: hi - lo,
      sign: sg, signName: SIGNS[sg],
      house,                                                // NATAL house — where in MY LIFE (§13.1)
      lord: rulerOfHouse(house, asc),                       // the segment's governor while occupied
    }));
  }
  // A boundary's own record, including the one thing a reader actually wants: does crossing it hand
  // the placement to a NEW lord, or is it a change of arena under the same governor? (The fixture's
  // Capricorn → Aquarius crossing is Saturn → Saturn, which is why this is worth storing.)
  const boundaries = segments.slice(0, -1).map((seg, i) => {
    const next = segments[i + 1];
    return Object.freeze({
      lon: next.startLon,
      fromSign: seg.sign, toSign: next.sign,
      fromHouse: seg.house, toHouse: next.house,
      fromLord: seg.lord, toLord: next.lord,
      lordChanges: seg.lord !== next.lord,
    });
  });
  return Object.freeze({
    center: arc.center, start: arc.start, end: arc.end,
    segments: Object.freeze(segments), boundaries: Object.freeze(boundaries),
  });
}

// ---------- 2 · the reachable set ----------
// The seven signs and seven houses a synchronic placement can EVER occupy, forever. A fact a native
// should be able to read, and one no other astrology app can state, because it only exists once the
// placement is understood as confined to an arc.
function reachableOf(natalLon, ascSignIdx) {
  const a = segmentsOf(natalLon, ascSignIdx);
  const signs = [], houses = [], lords = [];
  for (const seg of a.segments) {
    if (!signs.includes(seg.sign)) signs.push(seg.sign);
    if (!houses.includes(seg.house)) houses.push(seg.house);
    if (!lords.includes(seg.lord)) lords.push(seg.lord);
  }
  return Object.freeze({
    signs: Object.freeze(signs), signNames: Object.freeze(signs.map((i) => SIGNS[i])),
    houses: Object.freeze(houses), lords: Object.freeze(lords),
    // The complement is as much a fact as the set: five signs this placement can never reach.
    unreachableSigns: Object.freeze(SIGNS.map((_, i) => i).filter((i) => !signs.includes(i))),
  });
}

// ---------- 3 · the same-body families ----------
// THE PAIR HERE IS TWO NATIVES, NOT TWO BODIES. This is the distinction that decides whether the
// table exists at all, and getting it backwards produces a table that looks right and is wrong:
//   · SAME BODY, two natives — sMars_A − sMars_B = (natalA − natalB)/2. The sky term is the SAME term
//     on both sides and cancels EXACTLY, so the separation is fixed forever and has a family.
//   · TWO BODIES, one native — sMoon − sSun = (natMoon − natSun)/2 + (skyMoon − skySun)/2. The sky
//     term is a difference of two DIFFERENT bodies and does not cancel, so there is no family and
//     nothing to store. (Measured on the fixture while building this: the intra-chart Sun/Moon table
//     said 52.05°/127.95° and the real separation was 21.02° on the first sampled day.)
// So families belong to a PAIR OF CHARTS and never to one, which is why they are built by `buildPair`
// and are absent from `build`. A single native's prism has no family table, and that absence is
// correct rather than missing.
//
// The family is `{δ/2, 180−δ/2}` and only the MODE alternates, selected by φ_A ⊕ φ_B. Which marks the
// pair can ever form is settled at engrave — `orb` is the reader's cut, not a tolerance baked into the
// geometry. The square is SELF-COMPLEMENTARY (`{90, 90}`): a flip changes which side, not the class,
// so the mode display is suppressed rather than shown as a change.
function familiesOf(natalA, natalB, orb = 3) {
  const fam = beadFamily(ck(natalA, 'familiesOf'), ck(natalB, 'familiesOf'));
  const modes = fam.modes.map((m) => {
    const n = nearest(m);
    return Object.freeze({ separation: m, mark: n.angle, residual: n.residual, forms: n.residual <= orb });
  });
  return Object.freeze({
    natalSeparation: fam.sep,
    modes: Object.freeze(modes),
    selfComplementary: fam.selfComplementary,
    // The marks this pair can EVER form, at this orb. Empty is a legitimate answer: most pairs never
    // come to a mark on the synchronic layer at all, which is itself worth being able to say.
    canForm: Object.freeze([...new Set(modes.filter((m) => m.forms).map((m) => m.mark))].sort((a, b) => a - b)),
  });
}

// ---------- 4 · the itinerary · the sASC's day ----------
// §1.1's template, and the reason it is a template rather than a scan: the sASC's arc is the SAME arc
// law as every other occupant (arcFor(nASC)), so its seven stretches are exactly `segmentsOf(nASC)`.
// What is particular to the sASC is the ORDER it walks them in and the fact that it walks the whole
// thing between waking and sleeping:
//
//   anchor  the horizon reaches nASC · sASC sits at nASC · YOUR ASCENDANT RISING
//           forward through the 2nd, the 3rd, into the 4th
//   flip    the horizon opposes nASC · sASC jumps pole to pole · YOUR ASCENDANT SETTING
//           forward through the 11th, the 12th
//   home    the anchor again
//
// So traversal starts at the arc's CENTRE, runs to its far end, jumps to its near end, and returns to
// the centre. Two of the seven segments are therefore visited in halves (the one containing nASC), and
// the honest representation is a run of stretches rather than a partition — which is what this builds.
//
// A TRANSITION IS A CHANGE OF SYNCHRONIC ASCENDANT RULER, AND THE STEP IS A FIELD (§13.3). The daily
// inversion is NOT its own kind: crossing to the opposite pole changes the sign, the frame offset and
// the ruler, which is exactly what a boundary crossing changes. One kind, seven a day, six of step 1
// and one of step 6. Scoped to the sASC deliberately — Pluto's flip keeps its kind, its window and its
// weight, and nothing here touches framing.flipEvents.
function itineraryOf(natalAscLon, ascSignIdx) {
  ck(natalAscLon, 'itineraryOf'); const asc = ckSign(ascSignIdx, 'itineraryOf');
  const arc = segmentsOf(natalAscLon, asc);
  const c = natalAscLon;
  const cuts = cutsOf(c);
  // The walk, in real (unwrapped) coordinates so ordering is plain: centre → far end, then near end
  // → centre. Each leg is clipped against the arc's own cuts.
  const legs = [[c, c + 90, false], [c - 90, c, true]];
  const stops = [];
  for (const [lo, hi, afterFlip] of legs) {
    for (const seg of arc.segments) {
      const sLo = cuts[seg.index], sHi = cuts[seg.index + 1];
      const a = Math.max(lo, sLo), b = Math.min(hi, sHi);
      if (b - a <= 1e-9) continue;
      const house = seg.house;
      // §13.2 · the synchronic frame. synchronic house = natal house − (natal house of the sASC) + 1,
      // mod 12. The sASC's own natal house IS this stretch's house, so the offset is fixed per stop
      // and takes exactly seven values across the day.
      const frameOffset = ((1 - house) % 12 + 12) % 12;
      stops.push(Object.freeze({
        order: stops.length,
        sign: seg.sign, signName: seg.signName,
        house,                                              // the sASC's own NATAL house
        frameOffset,                                        // §13.2 · natal house → synchronic house
        lord: seg.lord,                                     // the Synchronic Ascendant Ruler
        spanDeg: b - a,
        // First-order duration only, and named so no reader mistakes it for a clock: it is the stretch
        // as a FRACTION OF THE DAY, which is what the arc alone can say. ASCENSION IS NOT UNIFORM, so
        // the real duration needs a latitude, and that is section 5's template (`templateOf`), which
        // carries `hours` beside this. Both are stored and neither is an event time: a duration has no
        // epoch, and the epoch is the one number a synchronic day is a template PLUS (§1.1).
        meanHours: (b - a) / SASC_DEG_PER_DAY * 24,
        afterFlip,
        startLon: norm360(a), endLon: norm360(b),
      }));
    }
  }
  // The two structural instants. Both are PLACE-BOUND in time (the anchor is found by
  // framing.findAscAnchor at the natal location) and place-free in geometry, so what is stored is the
  // geometry and the time is asked for when wanted.
  const anchorHouse = houseOfSign(signIndex(c), asc);
  const flipSign = signIndex(norm360(c + 180));
  return Object.freeze({
    sascLonAtAnchor: norm360(c),
    anchor: Object.freeze({
      sascLon: norm360(c), sign: signIndex(c), signName: SIGNS[signIndex(c)],
      house: anchorHouse, lord: rulerOfHouse(anchorHouse, asc),
      // At the anchor the two frames COINCIDE (offset 0) — which is a fresh justification for the
      // composite-chronology protocol from a direction it was not designed from: it samples at the one
      // instant a day when the moment's own frame IS the native's frame.
      frameOffset: ((1 - anchorHouse) % 12 + 12) % 12,
      note: 'the horizon reaches the natal Ascendant · your Ascendant rising',
    }),
    flip: Object.freeze({
      horizonLon: norm360(c + 180), sign: flipSign,
      // The flip's step is 6, which is the Tympan's own recorded fact that a flip moves a placement
      // exactly six houses, always. Read from the Tympan rather than restated.
      houseStep: FLIP_HOUSES,
      note: 'the horizon opposes the natal Ascendant · your Ascendant setting',
    }),
    stops: Object.freeze(stops),
    // §13.2's closure, computed rather than asserted: the offsets a day passes through, in order.
    offsets: Object.freeze([...new Set(stops.map((s) => s.frameOffset))]),
    lords: Object.freeze([...new Set(stops.map((s) => s.lord))]),
  });
}

// ---------- 5 · P3 · THE ASCENSION TEMPLATE · THE REAL DURATIONS ----------
// §1.1's other half. The itinerary above is uniform in DEGREES; the day is not uniform in TIME, and
// “the disagreement between them is the reading, not a rendering defect”. This section supplies the
// time, and it needs no ephemeris scan because the sASC's whole time-dependence is the horizon's own
// rotation, which is rigid.
//
// THE ONE IDENTITY THE SECTION RESTS ON. Let σ be how far the sASC has walked from the anchor, 0 to
// 180. The horizon is at `nASC + 2σ` for the WHOLE day, with no branch and no flip case: leg one has
// the sASC at `c + σ` (horizon `c + 2σ`), and leg two has it at `c + σ − 180` (horizon `c + 2σ − 360`,
// the same degree). So the sASC's 180° walk IS the horizon's single revolution, and the flip is simply
// σ = 90. The template is that map read through ascension.
//
// WHAT A DURATION IS, AND WHY STORING IT IS NOT STORING AN EVENT TIME. A duration has no epoch. The
// stretch “the sASC in the 11th lasts 2h26m” is a permanent signature of a latitude and a rising sign,
// constant to within seconds over a lifetime; “the sASC entered the 11th at 09:14” is an event and is
// refused here as it is everywhere else in the prism. What the template stores is a shape; the cursor
// supplies the epoch, through `ramcJdNear`, one line of rotation arithmetic and no scan.

// The RAMC at which an ecliptic degree rises at a latitude: oblique ascension, derived as the EXACT
// INVERSE of ephem's own `angles()` rather than from a textbook variant, so the two cannot disagree
// about what rises when. `angles` reads
//   asc = atan2(cos ra, −(sin ra·cosε + tanφ·sinε))
// which for a target asc L means cos ra = R·sin L and sin ra = (−R·cos L − tanφ·sinε)/cosε for some
// R > 0; sin² + cos² = 1 makes that a quadratic in R. Measured against `angles` at 3600 samples: max
// deviation 1.1e-13°.
//
// null is a REAL ANSWER, not a failure: below the polar circle (|φ| < 90 − ε) the quadratic's constant
// term is negative, so there is exactly one positive root and every degree rises. Above it some degrees
// never rise at all, and a native there has a synchronic day with pieces missing. The template says so
// rather than inventing a time.
function risingRamc(lon, lat, eps) {
  const L = norm360(ck(lon, 'risingRamc')) * D2R, e = eps * D2R, tf = Math.tan(lat * D2R);
  const cL = Math.cos(L), sL = Math.sin(L), ce = Math.cos(e), se = Math.sin(e);
  const A = sL * sL * ce * ce + cL * cL;
  const B = 2 * cL * tf * se;
  const C = tf * tf * se * se - ce * ce;
  const disc = B * B - 4 * A * C;
  if (!(disc >= 0)) return null;                        // circumpolar · this degree never rises here
  const R = (-B + Math.sqrt(disc)) / (2 * A);
  if (!(R > 0)) return null;
  return norm360(Math.atan2((-R * cL - tf * se) / ce, R * sL) * R2D);
}

// The epoch, supplied by rotation alone: the first instant at or after `jdNear` when the local RAMC
// reaches `ramcTarget`. No ephemeris, no bodies, no root-find over a sampled function — gmst is a
// polynomial in jd and near-rigid, so a linear guess plus three Newton steps closes it. This is §1.3's
// “one refinement iteration per row”, and it is the only place the template touches time.
function ramcJdNear(ramcTarget, jdNear, lonEast) {
  const local = (jd) => norm360(gmst(jd) + lonEast);
  let jd = jdNear + norm360(ramcTarget - local(jdNear)) / RAMC_RATE;
  for (let i = 0; i < 3; i++) jd += wrap180(ramcTarget - local(jd)) / RAMC_RATE;
  return jd;
}

// The template: the itinerary's seven stops with their REAL durations, plus the two structural
// instants as rotation angles and the offset's own arithmetic.
//
// Latitude only, deliberately. A duration is a function of latitude; only the EPOCH wants a longitude,
// which is why the anchor is stored as a RAMC here and turned into a jd by the reader. That split is
// also §8's result seen from the other side: the sASC is an angle, so it is the one layer in the
// instrument where place is content rather than a nuisance.
function templateOf(natalAscLon, ascSignIdx, lat, opts = {}) {
  const c = ck(natalAscLon, 'templateOf');
  if (!Number.isFinite(lat)) throw new Error('prism: templateOf needs a latitude — ascension is a fact of a place');
  const eps = opts.eps == null ? obliquity(opts.jd == null ? J2000 : opts.jd) : opts.eps;
  const it = itineraryOf(c, ascSignIdx);
  const limit = 90 - eps;
  // The horizon degree each stop opens at, through the one identity: H = nASC + 2σ.
  let sigma = 0;
  const raw = it.stops.map((st) => {
    const entry = { stop: st, horizonLon: norm360(c + 2 * sigma), sigma };
    sigma += st.spanDeg;
    return entry;
  });
  const ramcs = raw.map((e) => risingRamc(e.horizonLon, lat, eps));
  if (ramcs.some((r) => r == null)) {
    // Refused rather than approximated, and named so a reader can say it out loud.
    return Object.freeze({
      circumpolar: true, latitude: lat, epsilon: eps, polarCircle: limit,
      reason: 'above the polar circle (|latitude| ≥ ' + limit.toFixed(2) + '°) some ecliptic degrees never rise, '
        + 'so parts of the synchronic day have no arrival time at all. The template refuses to invent one.',
      stops: Object.freeze([]),
    });
  }
  const anchorRamc = risingRamc(norm360(c), lat, eps);
  const flipRamc = risingRamc(norm360(c + 180), lat, eps);
  // A stop's span in RAMC is the forward gap to the next stop's entry; the last closes on the anchor,
  // so the spans sum to exactly 360° by construction — one rotation, one synchronic day.
  const stops = raw.map((e, i) => {
    const span = norm360((i + 1 < ramcs.length ? ramcs[i + 1] : anchorRamc) - ramcs[i]);
    return Object.freeze({
      ...e.stop,
      horizonLon: e.horizonLon,
      // P4 · CODEC 3 · THE WALK THIS STRETCH OPENS AT. Computed here since P3 and discarded, which is
      // the `frameOffset` lesson again. It is the stop's address in the ONE continuous coordinate the
      // day has, so a reader can place a live cursor on the itinerary without re-deriving the sum.
      sigma: e.sigma,
      sigmaEnd: e.sigma + e.stop.spanDeg,
      ramc: ramcs[i],                                   // the rotation angle this stretch opens at
      ramcSpan: span,
      // Real duration, in mean solar hours. This is the number §1.1 promised and `meanHours` above
      // could not give: stretches of equal DEGREE run wildly unequal in TIME, permanently, as a
      // signature of latitude and rising sign.
      hours: span / RAMC_RATE * 24,
      seconds: span / RAMC_RATE * 86400,
    });
  });
  const totalRamc = stops.reduce((s, st) => s + st.ramcSpan, 0);
  const byHours = stops.slice().sort((a, b) => a.hours - b.hours);
  return Object.freeze({
    circumpolar: false, latitude: lat, epsilon: eps, polarCircle: limit,
    ascLon: norm360(c), ascSign: ascSignIdx,
    stops: Object.freeze(stops),
    // The two structural instants, as ROTATION ANGLES. `ramcJdNear` turns either into an epoch when a
    // reader wants one; nothing here is a time.
    anchor: Object.freeze({ horizonLon: norm360(c), ramc: anchorRamc, note: it.anchor.note }),
    flip: Object.freeze({ horizonLon: norm360(c + 180), ramc: flipRamc, houseStep: FLIP_HOUSES, note: it.flip.note }),
    day: Object.freeze({
      ramc: totalRamc,                                  // 360 by construction, checked at load
      siderealDays: 1, days: SIDEREAL_DAY, hours: SIDEREAL_DAY * 24,
      shortestStopHours: byHours[0].hours, longestStopHours: byHours[byHours.length - 1].hours,
      // The inequality, as one number: how many times longer the day's longest stretch is than its
      // shortest. Near a cusp this runs to hundreds, which is the sliver being structure again.
      unevenness: byHours[byHours.length - 1].hours / byHours[0].hours,
    }),
    // §1.2 · THE OFFSET, which is the “plus one number”. The template is fixed; what moves is its phase
    // against civil time, and that motion is pure sidereal arithmetic with no ephemeris in it.
    offset: Object.freeze({
      regressionDays: 1 - SIDEREAL_DAY,
      regressionMinutes: (1 - SIDEREAL_DAY) * 1440,      // 3m55.9s a day, the familiar number
      // And its own period is a year, which is §1.2's claim stated as arithmetic rather than intuition:
      // the anchor's civil time returns to itself after 1/(1 − S) anchors, and because each anchor is S
      // days apart that is S/(1 − S) days — 365.2422, the tropical year. The sidereal and solar days
      // beat at exactly one year, so the synchronic day is a fixed shape whose phase against the clock
      // completes one revolution annually. Not an analogy to a solar return; the same period.
      annualReturnAnchors: 1 / (1 - SIDEREAL_DAY),
      annualReturnDays: SIDEREAL_DAY / (1 - SIDEREAL_DAY),
    }),
  });
}

// ---------- 6 · P4 · THE RETURN · the dial, read from one sample ----------
// THE SYNCHRONIC DAY IS A RETURN, AND THE FLIP IS NOT ITS SUBJECT. The sASC leaves the natal
// Ascendant, walks, and comes home to the natal Ascendant, because sASC = midpoint(nASC, horizon) and
// the horizon makes exactly one revolution. Its value contains no time at all: nASC at 0° Aries and a
// horizon at 0° Taurus put the sASC at 15° Aries at every epoch there has ever been, which is why the
// map is a table and the day is that table plus one number.
//
// SO THE DIAL'S QUANTITY IS THE WALK, NOT THE JUMP. Let sigma be how far the sASC has walked from the
// anchor. P3's identity is `horizon = nASC + 2*sigma` for the whole day with no branch and no flip
// case, so sigma is simply `norm360(horizon - nASC)/2`: continuous, monotone, 0 to 180 across the day,
// and read from ONE sample with no previous sample and no stored state. Everything the dial shows is a
// function of it.
//
// WHICH DELETES THE FLIP AS A THING TO DETECT. The flip is sigma = 90, the far point of the excursion,
// the degree opposite the return. The WALK does not jump there; only the DRAWING does, because a 180°
// walk is being painted onto a 360° wheel and the far end of the arc is a different degree from the
// near end. A pole change is therefore an ordinary property of a position, `sigma >= 90`, exactly
// framing.phaseOf, and it changes what the Ring is measuring the placement against without changing
// anything about the placement's motion. It is a boundary crossing of the same class as the other six
// (itineraryOf already rules this: one kind, seven a day, six of step 1 and one of step 6).
//
// AND THAT IS WHY THE DIAL SURVIVES A SCRUB AT ANY RATE. Nothing here differences two samples, so
// there is no step size at which it degrades, no ordering requirement, and no state to corrupt when
// the cursor leaps. The old `Math.abs(wrap180(lon - prev)) > 150` test in the DC was a leap detector,
// and a leap detector cannot survive a cursor that leaps: the sASC moves 180° a day, so a fast scrub
// exceeds 150° with no crossing in the interval (a flip that did not happen) and can step across the
// real crossing under 150° (the one that did, swallowed). Never reintroduce a between-samples test.

// The walk, and the whole of P4's arithmetic. Pure: no time, no latitude, no ephemeris, one wrap and
// one halving. `refract` supplies the degree so that the one refraction door stays the one door.
function walkOf(natalAscLon, horizonLon) {
  const c = norm360(ck(natalAscLon, 'walkOf')), H = norm360(ck(horizonLon, 'walkOf'));
  const sigma = norm360(H - c) / 2;                   // [0, 180) · continuous and monotone through the day
  const pole = sigma >= 90 ? 1 : 0;                   // identical to framing.phaseOf(c, H), by construction
  return Object.freeze({
    sigma, pole,
    sascLon: refract(c, H),                           // the ONE refraction door
    horizonLon: H, ascLon: c,
    fraction: sigma / 180,                            // the day walked, IN DEGREES (see `drift` below)
    // The two structural instants as distances rather than times, so a reader with no latitude still
    // has a dial. Both wrap forward: at the flip the next flip is a whole day away.
    toFlipDeg: (90 - sigma + 180) % 180,
    toHomeDeg: 180 - sigma,
    // The pole is which END of the permitted arc the placement is walking toward, and it is the whole
    // content of a flip: same walk, other end, so the Ring measures from a degree six houses away.
    poleLon: norm360(c + (pole ? -90 : 90)),
    atHome: sigma === 0,
    atFlip: sigma === 90,
  });
}

// Where the walk is on the itinerary. The stops carry their own sigma since CODEC 3, so this is a
// lookup and not a re-derivation. Returns null for a circumpolar template, which has no stops.
function stopAtWalk(template, sigma) {
  if (!template || template.circumpolar || !template.stops.length) return null;
  const s = ((sigma % 180) + 180) % 180;
  for (let i = 0; i < template.stops.length; i++) {
    const st = template.stops[i];
    if (s >= st.sigma - 1e-9 && s < st.sigmaEnd - 1e-9) {
      const into = s - st.sigma;
      return Object.freeze({ stop: st, index: i, degIntoStop: into, degLeftInStop: st.spanDeg - into,
        degFraction: st.spanDeg > 0 ? into / st.spanDeg : 0 });
    }
  }
  const last = template.stops[template.stops.length - 1];
  return Object.freeze({ stop: last, index: template.stops.length - 1, degIntoStop: last.spanDeg,
    degLeftInStop: 0, degFraction: 1 });
}

// THE DIAL. One horizon degree in, the whole reading out, and the reading INCLUDES the disagreement
// §1.1 promised: `fraction` is the day walked in degrees, `timeFraction` is the day elapsed in time,
// and `drift` is the signed difference between them. Near a cusp that runs enormous, and it is the
// content rather than an error. Needs the template only for the time half; hand it null and the walk
// half still answers, so a chart with no place still has a dial.
function dialOf(template, natalAscLon, horizonLon, opts = {}) {
  const walk = walkOf(natalAscLon, horizonLon);
  if (!template || template.circumpolar) {
    return Object.freeze({ ...walk, at: null, timeFraction: null, drift: null,
      circumpolar: !!(template && template.circumpolar) });
  }
  const at = stopAtWalk(template, walk.sigma);
  const eps = template.epsilon;
  const ramc = risingRamc(walk.horizonLon, template.latitude, eps);
  if (ramc == null) return Object.freeze({ ...walk, at, timeFraction: null, drift: null, circumpolar: true });
  const elapsed = norm360(ramc - template.anchor.ramc);
  const hoursOf = (deg) => deg / RAMC_RATE * 24;
  const timeFraction = elapsed / 360;
  return Object.freeze({
    ...walk, at, ramc, circumpolar: false,
    elapsedRamc: elapsed, elapsedHours: hoursOf(elapsed),
    timeFraction,
    // The one number §1.1 has been asserting since the plan was written. Positive means the walk is
    // ahead of the clock (the sASC is crossing quick-rising stretches), negative means behind. It is
    // zero only at the anchor and wherever the two curves happen to cross.
    drift: walk.fraction - timeFraction,
    // Exact, from rotation alone: no scan, no ephemeris, no event stored anywhere.
    toFlipHours: hoursOf(norm360(template.flip.ramc - ramc)),
    toHomeHours: hoursOf(norm360(template.anchor.ramc - ramc)),
    hoursLeftInStop: at ? hoursOf(norm360(
      (at.index + 1 < template.stops.length ? template.stops[at.index + 1].ramc : template.anchor.ramc) - ramc)) : null,
    ...(opts.jd != null && Number.isFinite(opts.lonEast)
      // A reader that wants epochs asks for them; the template still stores none.
      ? { flipJd: ramcJdNear(template.flip.ramc, opts.jd, opts.lonEast),
          homeJd: ramcJdNear(template.anchor.ramc, opts.jd, opts.lonEast) }
      : {}),
  });
}

// ---------- the key ----------
// A named cut of the chart, exactly as artifact keys are named cuts of the genome. The structure
// depends on the natal longitudes (at arcsecond identity, the codec's own resolution), the ASC sign
// that houses them, the LATITUDE the ascension template is cut at, the occupant set it was built over,
// and doctrine. No longitude and no moment at all: the structure has neither, and a duration has no
// epoch. (CODEC 2 · the latitude arrived with P3, so a table filed at another place misses.)
function prismKey(natal, opts = {}, doctrineKey) {
  const names = (opts.bodies || BODIES).filter((b) => natal.pos && natal.pos[b] != null).slice().sort();
  const lons = names.map((b) => b + ':' + Math.round(norm360(natal.pos[b]) * ARCSEC));
  const ascPart = natal.asc == null ? 'x' : String(Math.round(norm360(natal.asc) * ARCSEC));
  const latPart = natal.lat == null ? 'x' : String(Math.round(natal.lat * ARCSEC));
  return 'p' + CODEC + '|' + ascPart + '|' + latPart + '|' + lons.join(',') + '|' + (doctrineKey || '');
}

// ---------- the one entry point ----------
// Built at engrave, frozen, and read forever. Refuses a chart with no horizon rather than inventing
// one: every table here is housed, and a house needs an Ascendant sign. (No Davison, no geodetic
// midpoint place, no invented horizon — the doctrine's own refusal, applied here.)
function build(natal, opts = {}) {
  if (!natal || !natal.pos) throw new Error('prism: build needs a natal with positions');
  if (natal.asc == null) throw new Error('prism: build needs a natal Ascendant — every table here is housed');
  const asc = signIndex(natal.asc);
  const orb = opts.orb == null ? 3 : opts.orb;
  const requested = opts.bodies || BODIES;
  // Lots are admitted as occupants and REFUSED an arc, per §14.2. Recorded rather than silently
  // dropped: a reader asking why Fortune has no reachable set gets the reason, not an absence.
  const names = requested.filter((b) => natal.pos[b] != null && !LOT_SET.has(b));
  const skippedLots = requested.filter((b) => LOT_SET.has(b));
  const lat = opts.lat == null ? (Number.isFinite(natal.lat) ? natal.lat : null) : opts.lat;

  const occupants = {};
  for (const b of names) {
    const arc = segmentsOf(natal.pos[b], asc);
    occupants[b] = Object.freeze({
      natalLon: norm360(natal.pos[b]),
      arc,
      reachable: reachableOf(natal.pos[b], asc),
    });
  }

  // Same-body families are a PAIR fact and live on buildPair, never here (see section 3). A single
  // native's prism has no family table by construction, and that absence is correct rather than
  // missing.

  return Object.freeze({
    codec: CODEC,
    ascSign: asc, ascSignName: SIGNS[asc], ascLon: norm360(natal.asc),
    occupants: Object.freeze(occupants),
    names: Object.freeze(names.slice()),
    itinerary: itineraryOf(natal.asc, asc),
    // P3 · the real durations, present only when the chart has a LATITUDE. A pp mint has no place by
    // doctrine (no Davison, no invented horizon), so it has no ascension template either, and that
    // absence is a ruling rather than a gap — recorded below beside the other refusals.
    template: lat == null ? null : templateOf(natal.asc, asc, lat, { jd: natal.jd, eps: opts.eps }),
    orb,
    deferred: Object.freeze({
      // Stated UNCONDITIONALLY, because it is a standing policy and not a report on this request. A
      // reader asking why Fortune has no reachable set gets the reason whether or not lots were asked
      // for on this build; a record that appears only sometimes is a record nobody can rely on.
      lots: 'lot arcs are not stored: sect is the synchronic chart\u2019s own (sSun against sASC), so a diurnal native can have a nocturnal synchronic chart, and then Fortune and Spirit exchange formulae and the two ends of the arc come from different equations. Lots are computed live from refracted Ascendant, Moon and Sun, which is exact under one sect and needs no table.',
      lotsRequested: Object.freeze(skippedLots.slice()),
      families: 'same-body families need TWO natives (the sky term cancels only body-against-itself) \u2014 see buildPair.',
      crossBody: 'cross-body separations are never tabled: (skyA \u2212 skyB)/2 does not cancel, so a cross-body pair can form any mark.',
      eventTimes: 'no event times, ever: the structure is stored and the cursor is read through it. The template stores DURATIONS, which have no epoch \u2014 the epoch comes from ramcJdNear at read time.',
      template: lat == null ? 'no ascension template: this chart has no latitude, and a duration is a fact of a place. A composite is given no invented horizon and no geodetic midpoint place, so it has no template either.' : null,
    }),
  });
}

// ---------- 7 · P5 · THE LEDGER · a row is a bare rotation lookup ----------
// See prism.js for the full doc comment. stopAtRamc answers "which row" from the local RAMC directly,
// with no walk, no horizon and no ephemeris beyond gmst — the same cumulative sum templateOf used to
// CUT the day, read through a different door; the two must always agree (checked below, not assumed).
function stopAtRamc(template, ramcTarget) {
  if (!template || template.circumpolar || !template.stops.length) return null;
  const off = norm360(ck(ramcTarget, 'stopAtRamc') - template.stops[0].ramc);
  let cum = 0;
  for (let i = 0; i < template.stops.length; i++) {
    const st = template.stops[i];
    if (off < cum + st.ramcSpan - 1e-9) return Object.freeze({ stop: st, index: i, ramcInto: off - cum, ramcLeft: st.ramcSpan - (off - cum) });
    cum += st.ramcSpan;
  }
  const last = template.stops[template.stops.length - 1];
  return Object.freeze({ stop: last, index: template.stops.length - 1, ramcInto: last.ramcSpan, ramcLeft: 0 });
}
function localRamc(jd, lonEast) { return norm360(gmst(jd) + lonEast); }

// ---------- 8 · P5 · THE MARKS · sASC-vs-occupant, on the one scanner ----------
// See prism.js for the full doc comment: a mark "to occupant P" is an ordinary mode:'sep' target
// between two occupants where one is the sASC, so this needs NO change to loom.js — the caller hands
// scanTargets a probe answering `Asc` (the horizon) alongside the ordinary bodies. The Moon is
// excluded by default (she is luna.js's business, per §1.3).
const LEDGER_BODIES_DEFAULT = BODIES.filter((b) => b !== 'Moon' && b !== 'SNode');
function sascTargets(natal, opts = {}) {
  if (!natal || !natal.pos || natal.asc == null) return [];
  const bodies = (opts.bodies || LEDGER_BODIES_DEFAULT).filter((b) => b !== 'SNode' && natal.pos[b] != null);
  const angles = opts.aspects || [0, 60, 90, 120, 180];
  const out = [];
  for (const b of bodies) {
    for (const ang of angles) for (const s of (ang === 0 || ang === 180 ? [ang] : [ang, -ang])) {
      out.push({ layer: 'synchronic', kind: 'aspect', mode: 'sep', body: 'Asc', other: b,
        nat: norm360(natal.asc), natOther: natal.pos[b], angle: ang, deg: s, confirm: SYN_CONFIRM });
    }
  }
  return out;
}
function ledgerMarks(natal, template, probe, jdStart, jdEnd, opts = {}) {
  if (!template || template.circumpolar) return [];
  const targets = sascTargets(natal, opts);
  if (!targets.length) return [];
  const roots = scanTargets({ targets, jdStart, jdEnd, probe, step: opts.step || 0.01 });
  const lonEast = opts.lonEast;
  const orbBase = opts.natalOrb != null ? opts.natalOrb : 6;
  return roots.map((r) => {
    const t = r.target;
    const angle = Math.abs(t.angle);
    const asp = ASPECTS.find((a) => a.angle === angle);
    const at = Number.isFinite(lonEast) ? stopAtRamc(template, localRamc(r.jd, lonEast)) : null;
    return Object.freeze({
      jd: r.jd, body: t.other, angle, name: asp ? asp.name : String(angle), glyph: asp ? asp.glyph : '',
      retro: r.retro, orb: synOrb(angle, orbBase), rowIndex: at ? at.index : null,
    });
  }).sort((a, b) => a.jd - b.jd);
}
function ledgerOf(natal, template, probe, jdStart, jdEnd, opts = {}) {
  if (!template || template.circumpolar) return null;
  const marks = ledgerMarks(natal, template, probe, jdStart, jdEnd, opts);
  const rows = template.stops.map((st, i) => Object.freeze({ stop: st, index: i,
    marks: Object.freeze(marks.filter((m) => m.rowIndex === i)) }));
  return Object.freeze({ jdStart, jdEnd, rows: Object.freeze(rows), marks: Object.freeze(marks) });
}

// ---------- 9 · P6 · THE QUERY · seven windows, not a grid ----------
// See prism.js for the full doc comment. Not a second electional engine: reuses framing.PROFILES for
// vocabulary and P5's ledgerOf verbatim for marks (one path to a mark, never two).
const HARMONY = { 0: 0, 60: 1, 90: -1, 120: 1, 180: -1 };
function stopSigWeight(body, prof) { return prof.sigs.includes(body) ? 1.6 : prof.holders.includes(body) ? 1.15 : 0; }
function scoreStop(row, prof) {
  const st = row.stop;
  const drivers = [];
  const push = (v, t) => { if (Math.abs(v) > 1e-9) drivers.push({ v, t }); };
  if (prof.houses.includes(st.house)) push(0.8, 'the stop\u2019s house (H' + st.house + ') is the matter\u2019s own');
  if (prof.holders.includes(st.lord)) push(0.6, 'the Synchronic Ascendant Ruler is ' + st.lord + ', one of the matter\u2019s holders');
  for (const m of row.marks) {
    const w = stopSigWeight(m.body, prof);
    if (!w) continue;
    const h = HARMONY[m.angle] != null ? HARMONY[m.angle] : 0;
    if (h) push(w * h * 0.5, 'sASC ' + m.name + ' ' + m.body);
  }
  return { score: drivers.reduce((s, d) => s + d.v, 0), drivers };
}
function queryOf(natal, template, probe, jdStart, jdEnd, profile, opts = {}) {
  if (!template || template.circumpolar || !profile) return null;
  const lonEast = opts.lonEast;
  if (!Number.isFinite(lonEast)) return null;
  const ledger = ledgerOf(natal, template, probe, jdStart, jdEnd, opts);
  if (!ledger) return null;
  const candidates = [];
  for (const row of ledger.rows) {
    const st = row.stop;
    const { score: stopScore, drivers: stopDrivers } = scoreStop(row, profile);
    const jdMid = ramcJdNear(norm360(st.ramc + st.ramcSpan / 2), jdStart, lonEast);
    const insts = [{ jd: jdMid, why: 'the middle of the stretch' }].concat(
      row.marks.map((m) => ({ jd: m.jd, why: 'sASC ' + m.name + ' ' + m.body })));
    for (const inst of insts) {
      const at = stopAtRamc(template, localRamc(inst.jd, lonEast));
      if (!at || at.index !== row.index) continue;
      const edgeFrac = st.ramcSpan > 0 ? Math.min(at.ramcInto, at.ramcLeft) / st.ramcSpan : 0.5;
      const edgeScore = Math.min(0.15, edgeFrac) - 0.15;
      candidates.push({
        jd: inst.jd, rowIndex: row.index, stop: st, why: inst.why,
        score: stopScore + edgeScore,
        drivers: stopDrivers.concat([{ v: edgeScore, t: edgeScore >= -1e-9 ? 'well inside the stretch, away from a handoff' : 'close to a Synchronic Ascendant Ruler handoff' }]),
        marks: row.marks,
      });
    }
  }
  candidates.sort((a, b) => b.score - a.score || a.jd - b.jd);
  return Object.freeze({ jdStart, jdEnd, candidates: Object.freeze(candidates), rows: ledger.rows });
}

// ---------- the pair ----------
// Synchronic synastry's STRUCTURE: the same-body family for every body two natives share. Needs no
// sky, no moment and no place, which is the whole point and the reason two people export
// byte-identical flip calendars. Only ANGLES depend on place, and no angle appears here.
function buildPair(natalA, natalB, opts = {}) {
  if (!natalA || !natalA.pos || !natalB || !natalB.pos) throw new Error('prism: buildPair needs two natals with positions');
  const orb = opts.orb == null ? 3 : opts.orb;
  const requested = opts.bodies || BODIES;
  const names = requested.filter((b) => natalA.pos[b] != null && natalB.pos[b] != null && !LOT_SET.has(b));
  const families = {};
  for (const b of names) families[b] = familiesOf(natalA.pos[b], natalB.pos[b], orb);
  return Object.freeze({
    codec: CODEC,
    names: Object.freeze(names.slice()),
    families: Object.freeze(families),
    orb,
    // Every mark this pair can ever form, across every shared body. A short list, and a permanent one.
    canForm: Object.freeze([...new Set(names.flatMap((b) => families[b].canForm))].sort((a, b) => a - b)),
    note: 'same-body only: cross-body contacts genuinely form and separate, and have no family.',
  });
}

// ---------- the load-time completeness check ----------
// The Ring's discipline: prove the tables at stamp time rather than trusting them. Anything provable
// about the construction is proved here, so a broken build fails loudly at load and not in a reader.
(function selfTest() {
  const who = 'prism: ';
  // A generic degree cuts its arc into seven signs; a cusp degree into six. Both are correct and the
  // second is the one a sampled implementation gets wrong.
  const gen = segmentsOf(15.5, 0), cusp = segmentsOf(0, 0);
  if (gen.segments.length !== SEG_PER_ARC + 1) throw new Error(who + 'self-test: a generic arc should cut into ' + (SEG_PER_ARC + 1) + ' segments');
  if (cusp.segments.length !== SEG_PER_ARC) throw new Error(who + 'self-test: an arc starting on a cusp should cut into ' + SEG_PER_ARC);
  // Spans must tile the arc exactly — 180°, no gap and no overlap.
  const total = gen.segments.reduce((s, g) => s + g.spanDeg, 0);
  if (Math.abs(total - 180) > 1e-9) throw new Error(who + 'self-test: segments do not tile the arc (' + total + ')');
  // The centre is the natal degree, by the arc law.
  if (Math.abs(wrap180(gen.center - 15.5)) > 1e-9) throw new Error(who + 'self-test: the arc centre is not the natal degree');
  // A same-body family is a supplement pair, always, and the square is self-complementary.
  const sq = familiesOf(0, 180);
  if (!sq.selfComplementary) throw new Error(who + 'self-test: {90,90} should be self-complementary');
  const f = familiesOf(0, 60);
  if (Math.abs(f.modes[0].separation + f.modes[1].separation - 180) > 1e-9) throw new Error(who + 'self-test: the two modes should sum to 180');
  // §13.2 · the day makes exactly one full revolution against the natal frame, in seven steps.
  const it = itineraryOf(15.5, 0);
  if (it.offsets.length !== 7) throw new Error(who + 'self-test: the day should pass through seven frame offsets, got ' + it.offsets.length);
  if (it.flip.houseStep !== FLIP_HOUSES) throw new Error(who + 'self-test: the flip step is the Tympan\u2019s FLIP_HOUSES');
  const walked = it.stops.reduce((s, st) => s + st.spanDeg, 0);
  if (Math.abs(walked - 180) > 1e-9) throw new Error(who + 'self-test: the sASC should walk exactly 180\u00b0 a day, got ' + walked);
  if (Math.abs(it.stops.reduce((s, st) => s + st.meanHours, 0) - 24) > 1e-9) throw new Error(who + 'self-test: the stops should sum to 24 mean hours');
  if (it.anchor.frameOffset !== 0) throw new Error(who + 'self-test: at the anchor the two frames must coincide');
  // Every stop must CARRY its offset. It did not, once: the value was computed and never put on the
  // record, so the day reported one offset instead of seven and the omission was otherwise silent.
  if (it.stops.some((st) => !Number.isInteger(st.frameOffset))) throw new Error(who + 'self-test: every stop must carry a frame offset');
  // Every stop must carry its frame offset. It did not, once: the offset was computed and never put
  // on the record, so the day reported ONE offset instead of seven and the omission was silent.
  if (it.stops.some((s) => !Number.isInteger(s.frameOffset))) throw new Error(who + 'self-test: every stop must carry a frame offset');
  // ── P3 · the ascension template ──────────────────────────────────────────────────────────
  // The spans must tile the ROTATION exactly, the way the arc's tile 180°: one synchronic day is one
  // revolution of the horizon, so 360° of RAMC, no gap and no overlap.
  const tp = templateOf(15.5, 0, 43.07, { eps: 23.44 });
  if (Math.abs(tp.day.ramc - 360) > 1e-9) throw new Error(who + 'self-test: the template must tile one full rotation, got ' + tp.day.ramc);
  if (Math.abs(tp.stops.reduce((s, st) => s + st.hours, 0) - SIDEREAL_DAY * 24) > 1e-9) throw new Error(who + 'self-test: the real durations must sum to one sidereal day');
  // Every stop must CARRY its ramc and its duration, the P2 lesson applied again: a value computed and
  // not recorded is invisible to every reader.
  if (tp.stops.some((st) => !Number.isFinite(st.ramc) || !(st.hours > 0))) throw new Error(who + 'self-test: every stop must carry a rotation angle and a positive duration');
  // The one identity the section rests on: the flip is σ = 90, which is the horizon opposing nASC.
  if (Math.abs(wrap180(tp.flip.horizonLon - (15.5 + 180))) > 1e-9) throw new Error(who + 'self-test: the flip is the horizon opposite the natal Ascendant');
  // The durations are UNEQUAL, permanently. If they ever come out uniform the template has silently
  // become the degree walk again, which is the defect this section exists to remove.
  if (!(tp.day.unevenness > 1.2)) throw new Error(who + 'self-test: ascension is not uniform — equal degrees must give unequal times');
  // Above the polar circle the template refuses rather than approximating.
  if (!templateOf(15.5, 0, 78, { eps: 23.44 }).circumpolar) throw new Error(who + 'self-test: above the polar circle the template must refuse');
  // ── P4 · the return ────────────────────────────────────────────────────────────────────────
  // THE DAY IS A RETURN. The horizon at the natal Ascendant puts the sASC on the natal Ascendant,
  // which is both ends of the walk and the reason the flip is not the subject.
  if (Math.abs(wrap180(walkOf(15.5, 15.5).sascLon - 15.5)) > 1e-12) throw new Error(who + 'self-test: at the anchor the sASC IS the natal Ascendant');
  if (walkOf(15.5, 15.5).sigma !== 0) throw new Error(who + 'self-test: the walk starts at zero');
  // The user's own example, which is the whole table in one line: nASC 0° Aries, horizon 0° Taurus,
  // sASC 15° Aries. No epoch appears anywhere in it.
  if (Math.abs(walkOf(0, 30).sascLon - 15) > 1e-12) throw new Error(who + 'self-test: nASC 0 Aries with the horizon at 0 Taurus puts the sASC at 15 Aries');
  // P3's identity, from the other side: the horizon is nASC + 2σ everywhere, with no flip case.
  for (let H = 0; H < 360; H += 0.37) {
    const w = walkOf(15.5, H);
    if (Math.abs(wrap180(15.5 + 2 * w.sigma - H)) > 1e-9) throw new Error(who + 'self-test: horizon must equal nASC + 2 sigma at every degree');
    // The placement never leaves its permitted arc. This is the arc law, and it is what confines the
    // sASC to one half of the wheel in the composite frame.
    if (Math.abs(wrap180(w.sascLon - 15.5)) > 90 + 1e-9) throw new Error(who + 'self-test: the sASC left its arc at horizon ' + H);
  }
  // The flip is σ = 90 and nothing else, and it is an ARC END rather than the centre. That single
  // assertion is what distinguishes the flip from the return, which is the other pole change in the
  // day and is not a flip at all.
  const atFlip = walkOf(15.5, norm360(15.5 + 180));
  if (atFlip.sigma !== 90) throw new Error(who + 'self-test: the flip is sigma = 90');
  if (Math.abs(Math.abs(wrap180(atFlip.sascLon - 15.5)) - 90) > 1e-9) throw new Error(who + 'self-test: at the flip the sASC is at an END of its arc, never the centre');
  // The pole bit is a property of ONE sample and must agree with framing's own parity everywhere.
  for (let H = 0; H < 360; H += 1.7) {
    const w = walkOf(15.5, H);
    if (w.pole !== (norm360(H - 15.5) >= 180 ? 1 : 0)) throw new Error(who + 'self-test: the pole bit must be framing.phaseOf');
  }
  // The dial places the walk on the itinerary, and the stops must cover it with no hole.
  for (let s = 0; s < 180; s += 0.31) {
    if (!stopAtWalk(tp, s)) throw new Error(who + 'self-test: the itinerary must cover every walk value, missed ' + s);
  }
  if (stopAtWalk(tp, 0).index !== 0) throw new Error(who + 'self-test: the walk opens on the first stop');
  // Every stop must CARRY its walk, the CODEC 3 lesson and the third time this file has learned it.
  if (tp.stops.some((st) => !Number.isFinite(st.sigma) || !Number.isFinite(st.sigmaEnd))) throw new Error(who + 'self-test: every stop must carry the walk it opens at');
  if (Math.abs(tp.stops[tp.stops.length - 1].sigmaEnd - 180) > 1e-9) throw new Error(who + 'self-test: the stops must tile the whole walk');
  // A chart with no place still has a dial: the walk half needs no latitude.
  if (dialOf(null, 15.5, 100).sigma == null) throw new Error(who + 'self-test: a placeless chart still gets a walk');
  // ── P5 · the ledger ────────────────────────────────────────────────────────────────────────
  // THE BAR, proved WITHOUT a probe: see prism.js for the full comment. Structural half only \u2014 the
  // physically-live cross-check against E.angles lives in tests/prism.test.html.
  const tp5 = templateOf(15.5, 0, 43.07, { eps: 23.44 });
  for (let sigma = 0; sigma < 180; sigma += 0.29) {
    const ramcHere = risingRamc(norm360(15.5 + 2 * sigma), 43.07, 23.44);
    const viaRamc = stopAtRamc(tp5, ramcHere).index;
    const viaWalk = stopAtWalk(tp5, sigma).index;
    if (viaRamc !== viaWalk) throw new Error(who + 'self-test: RAMC-row and walk-row disagree at sigma ' + sigma);
  }
  if (stopAtRamc(tp5, tp5.stops[0].ramc).index !== 0) throw new Error(who + 'self-test: the anchor\u2019s own ramc opens the first row');
  const natal5 = { asc: 15.5, pos: { Mercury: 40, Venus: 100, Mars: 200, Jupiter: 260, Saturn: 300 } };
  const lonEast5 = -89.4, jd0 = 2460000;
  const probe5 = (jd) => {
    const out = { Asc: norm360((jd - jd0) * RAMC_RATE + tp5.anchor.horizonLon) };
    for (const b in natal5.pos) out[b] = natal5.pos[b];
    return out;
  };
  const jdEnd5 = ramcJdNear(tp5.anchor.ramc, jd0 + 0.9, lonEast5);
  const lg5 = ledgerOf(natal5, tp5, probe5, jd0, jdEnd5, { lonEast: lonEast5 });
  if (!lg5) throw new Error(who + 'self-test: the ledger must build on a non-circumpolar template');
  if (lg5.rows.length !== tp5.stops.length) throw new Error(who + 'self-test: one row per stop, got ' + lg5.rows.length + ' rows for ' + tp5.stops.length + ' stops');
  const totalMarks = lg5.rows.reduce((s, r) => s + r.marks.length, 0);
  if (totalMarks !== lg5.marks.length) throw new Error(who + 'self-test: every mark lands in exactly one row');
  if (totalMarks === 0) throw new Error(who + 'self-test: the fixture must produce at least one mark to be a test at all');
  if (lg5.marks.some((m) => m.rowIndex == null || m.rowIndex < 0 || m.rowIndex >= tp5.stops.length)) throw new Error(who + 'self-test: every mark must carry a valid row index');
  if (lg5.marks.some((m) => m.body === 'Moon')) throw new Error(who + 'self-test: the Moon is excluded from the ledger\u2019s default bodies');
  // ── P6 · the query ────────────────────────────────────────────────────────────────────────────────────────
  const profQ = { sigs: ['Mercury'], holders: ['Venus'], houses: [tp5.stops[0].house] };
  const q5 = queryOf(natal5, tp5, probe5, jd0, jdEnd5, profQ, { lonEast: lonEast5 });
  if (!q5) throw new Error(who + 'self-test: the query must build on a non-circumpolar, placed template');
  if (!q5.candidates.length) throw new Error(who + 'self-test: the fixture must produce at least one candidate to be a test at all');
  if (q5.candidates.some((c) => c.stop !== tp5.stops[c.rowIndex])) throw new Error(who + 'self-test: a candidate stop must be template.stops[i] itself');
  if (q5.candidates.some((c) => c.marks !== q5.rows[c.rowIndex].marks)) throw new Error(who + 'self-test: a candidate marks list must be the ledger row.marks itself');
  const q5b = queryOf(natal5, tp5, probe5, jd0, jdEnd5, profQ, { lonEast: lonEast5 });
  const dump = (q) => JSON.stringify(q.candidates.map((c) => [c.jd, c.rowIndex, c.score]));
  if (dump(q5) !== dump(q5b)) throw new Error(who + 'self-test: the query must be deterministic');
  const rowA = { stop: { house: 5, lord: 'Venus' }, marks: [] };
  const rowB = { stop: { house: 5, lord: 'Venus', afterFlip: true }, marks: [] };
  if (scoreStop(rowA, profQ).score !== scoreStop(rowB, profQ).score) throw new Error(who + 'self-test: the flip must not be a special case in the scorer');
  if (q5.candidates.some((c) => c.drivers.some((d) => /matter.s holders/.test(d.t) && !/Synchronic Ascendant Ruler/.test(d.t))))
    throw new Error(who + 'self-test: a lord driver must always say Synchronic Ascendant Ruler in full');
  if (queryOf(natal5, tp5, probe5, jd0, jdEnd5, profQ, {}) !== null) throw new Error(who + 'self-test: no lonEast means no query');
  if (queryOf(natal5, { ...tp5, circumpolar: true }, probe5, jd0, jdEnd5, profQ, { lonEast: lonEast5 }) !== null) throw new Error(who + 'self-test: a circumpolar template gets no query');
  // ── P7 · synastry ──────────────────────────────────────────────────────────────────────────
  const natA7 = { asc: 10, pos: { Mercury: 40, Venus: 100, Mars: 200 } };
  const natB7 = { asc: 55, pos: { Mercury: 40, Venus: 260, Mars: 5 } };
  const ascFam7 = familiesOf(natA7.asc, natB7.asc);
  const modes7 = ascFam7.modes.map((m) => m.separation);
  let worstSamePlace = 0;
  for (let h = 0; h < 360; h += 3.7) {
    const sascA = walkOf(natA7.asc, h).sascLon, sascB = walkOf(natB7.asc, h).sascLon;
    const sep = Math.abs(wrap180(sascA - sascB));
    worstSamePlace = Math.max(worstSamePlace, Math.min(Math.abs(sep - modes7[0]), Math.abs(sep - modes7[1])));
  }
  if (worstSamePlace > 1e-9) throw new Error(who + 'self-test: same place must hold the sASC separation to the pair\u2019s own family, drifted ' + worstSamePlace);
  let strays = 0, worstStray = 0, n = 0;
  for (let h = 0; h < 360; h += 3.7) {
    const hB = norm360(h * 7 + 40);
    const sascA = walkOf(natA7.asc, h).sascLon, sascB = walkOf(natB7.asc, hB).sascLon;
    const sep = Math.abs(wrap180(sascA - sascB));
    const d = Math.min(Math.abs(sep - modes7[0]), Math.abs(sep - modes7[1]));
    if (d > 0.5) strays++;
    worstStray = Math.max(worstStray, d);
    n++;
  }
  if (!(strays > n / 2 && worstStray > 5)) throw new Error(who + 'self-test: a genuinely different horizon relationship must make the sASC separation stray from the same-place family');
  const famAB = familiesOf(natA7.pos.Mercury, natB7.pos.Mercury);
  const famBA = familiesOf(natB7.pos.Mercury, natA7.pos.Mercury);
  if (Math.abs(famAB.natalSeparation - famBA.natalSeparation) > 1e-12) throw new Error(who + 'self-test: A\u00d7B must equal B\u00d7A for a same-body family');
  const bp7 = buildPair(natA7, natB7);
  if (!bp7.families.Mercury || !bp7.families.Venus || !bp7.families.Mars) throw new Error(who + 'self-test: buildPair must carry a family for every shared body');
  const sq7 = familiesOf(0, 180);
  if (!sq7.selfComplementary) throw new Error(who + 'self-test: {90,90} must stay self-complementary on the pair path too');
})();

window.__ORBO_PRISM = { CODEC, RAMC_RATE, SIDEREAL_DAY, segmentsOf, reachableOf, familiesOf, itineraryOf, risingRamc, ramcJdNear, templateOf, walkOf, stopAtWalk, dialOf, prismKey, build, buildPair, stopAtRamc, localRamc, sascTargets, ledgerMarks, ledgerOf, queryOf };
})();
