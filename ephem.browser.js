// ephem.browser.js — auto-generated browser-global build of ephem.js (no ES modules; assigns window.__ORBO_EPH).
// Source of truth is ephem.js — regenerate this file if ephem.js changes, don't hand-edit.
(function(){
// ephem.js — compact ephemeris engine (geocentric ecliptic longitudes of date)
// Sun/planets: JPL approximate Keplerian elements, officially fit/documented for 1800–2050
// (typical accuracy < a few arcmin in that window). The host UI's JD_MIN/JD_MAX are set to
// 1700–2150, a 100yr cushion each side beyond the documented fit. This is a smooth linear-in-T
// polynomial with no cutoff at 1800/2050 — there's no discontinuity at the boundary — but the
// unmodeled secular perturbations JPL's longer 3000BC–3000AD fit corrects for are absent here,
// so error grows gradually past the fit window. Spot-checked 2026-07-09 against known anchors:
// equinox/solstice Sun longitude within ~0.01° at 2000/2020, ~0.1° by 2100; the Dec 21 2020
// Jupiter–Saturn great conjunction reproduces to ~3 arcmin. Do not widen further without
// re-checking — Pluto/outer-planet error is the first to grow beyond arcmin-class at the edges.
// Moon: truncated Meeus ch.47 series (~0.01–0.05°, valid over many centuries by design).
// Node/Lilith: mean elements. Chiron: osculating Kepler (~1°, degrades faster — short-arc fit).

const D2R = Math.PI / 180, R2D = 180 / Math.PI;
function norm360(x) { x %= 360; return x < 0 ? x + 360 : x; }
function wrap180(x) { x = norm360(x); return x > 180 ? x - 360 : x; }

// ---------- time ----------
function julianDay(y, mo, d, h = 0, mi = 0, s = 0, utcOffset = 0) {
  const ut = h + mi / 60 + s / 3600 - utcOffset;
  let Y = y, M = mo; const D = d + ut / 24;
  if (M <= 2) { Y -= 1; M += 12; }
  const A = Math.floor(Y / 100), B = 2 - A + Math.floor(A / 4);
  return Math.floor(365.25 * (Y + 4716)) + Math.floor(30.6001 * (M + 1)) + D + B - 1524.5;
}
function jdToDate(jd) { // returns JS Date (UTC)
  return new Date((jd - 2440587.5) * 86400000);
}
function deltaTdays(jd) {
  const t = (jd - 2451545) / 365.25; // years since 2000
  const dt = 63.9 + 0.31 * t + 0.006 * t * t; // seconds, ok 1950–2050
  return dt / 86400;
}

// ---------- Kepler / planets ----------
// [a, aDot, e, eDot, I, IDot, L, LDot, w̄, w̄Dot, Ω, ΩDot]  (deg, deg/century)
const EL = {
  Mercury: [0.38709927, 0.00000037, 0.20563593, 0.00001906, 7.00497902, -0.00594749, 252.25032350, 149472.67411175, 77.45779628, 0.16047689, 48.33076593, -0.12534081],
  Venus:   [0.72333566, 0.00000390, 0.00677672, -0.00004107, 3.39467605, -0.00078890, 181.97909950, 58517.81538729, 131.60246718, 0.00268329, 76.67984255, -0.27769418],
  Earth:   [1.00000261, 0.00000562, 0.01671123, -0.00004392, -0.00001531, -0.01294668, 100.46457166, 35999.37244981, 102.93768193, 0.32327364, 0, 0],
  Mars:    [1.52371034, 0.00001847, 0.09339410, 0.00007882, 1.84969142, -0.00813131, -4.55343205, 19140.30268499, -23.94362959, 0.44441088, 49.55953891, -0.29257343],
  Jupiter: [5.20288700, -0.00011607, 0.04838624, -0.00013253, 1.30439695, -0.00183714, 34.39644051, 3034.74612775, 14.72847983, 0.21252668, 100.47390909, 0.20469106],
  Saturn:  [9.53667594, -0.00125060, 0.05386179, -0.00050991, 2.48599187, 0.00193609, 49.95424423, 1222.49362201, 92.59887831, -0.41897216, 113.66242448, -0.28867794],
  Uranus:  [19.18916464, -0.00196176, 0.04725744, -0.00004397, 0.77263783, -0.00242939, 313.23810451, 428.48202785, 170.95427630, 0.40805281, 74.01692503, 0.04240589],
  Neptune: [30.06992276, 0.00026291, 0.00859048, 0.00005105, 1.77004347, 0.00035372, -55.12002969, 218.45945325, 44.96476227, -0.32241464, 131.78422574, -0.00508664],
  Pluto:   [39.48211675, -0.00031596, 0.24882730, 0.00005170, 17.14001206, 0.00004818, 238.92903833, 145.20780515, 224.06891629, -0.04062942, 110.30393684, -0.01183482],
};
function keplerE(M, e) { // M in radians
  let E = M + e * Math.sin(M);
  for (let i = 0; i < 12; i++) {
    const dE = (E - e * Math.sin(E) - M) / (1 - e * Math.cos(E));
    E -= dE; if (Math.abs(dE) < 1e-10) break;
  }
  return E;
}
function helioXYZ(el, T) {
  const a = el[0] + el[1] * T, e = el[2] + el[3] * T, I = (el[4] + el[5] * T) * D2R;
  const L = el[6] + el[7] * T, wb = el[8] + el[9] * T, Om = el[10] + el[11] * T;
  const w = (wb - Om) * D2R, OmR = Om * D2R;
  let M = norm360(L - wb) * D2R;
  const E = keplerE(M, e);
  const xp = a * (Math.cos(E) - e), yp = a * Math.sqrt(1 - e * e) * Math.sin(E);
  const cw = Math.cos(w), sw = Math.sin(w), cO = Math.cos(OmR), sO = Math.sin(OmR), ci = Math.cos(I), si = Math.sin(I);
  return [
    (cw * cO - sw * sO * ci) * xp + (-sw * cO - cw * sO * ci) * yp,
    (cw * sO + sw * cO * ci) * xp + (-sw * sO + cw * cO * ci) * yp,
    (sw * si) * xp + (cw * si) * yp,
  ];
}
function precessionToDate(T) { return 5029.0966 / 3600 * T; } // deg from J2000 to date

// Chiron osculating elements near J2000 (heliocentric, J2000 ecliptic)
const CHIRON = { a: 13.6981, e: 0.38115, i: 6.9367, Om: 209.3814, w: 339.4592, M0: 27.54, n: 0.019442, epoch: 2451545.0 };
// generic osculating-Kepler small body, same recipe as Chiron: {a,e,i,Om,w,M0,n,epoch} -> heliocentric J2000 xyz (AU)
function keplerBodyXYZ(el, jdTT) {
  const M = norm360(el.M0 + el.n * (jdTT - el.epoch)) * D2R;
  const E = keplerE(M, el.e);
  const xp = el.a * (Math.cos(E) - el.e), yp = el.a * Math.sqrt(1 - el.e * el.e) * Math.sin(E);
  const w = el.w * D2R, O = el.Om * D2R, i = el.i * D2R;
  const cw = Math.cos(w), sw = Math.sin(w), cO = Math.cos(O), sO = Math.sin(O), ci = Math.cos(i), si = Math.sin(i);
  return [
    (cw * cO - sw * sO * ci) * xp + (-sw * cO - cw * sO * ci) * yp,
    (cw * sO + sw * cO * ci) * xp + (-sw * sO + cw * cO * ci) * yp,
    (sw * si) * xp + (cw * si) * yp,
  ];
}
function chironXYZ(jdTT) { return keplerBodyXYZ(CHIRON, jdTT); }

// Four major asteroids — osculating elements near J2000 (heliocentric, J2000 ecliptic).
// Same accuracy class as Chiron above (~1-2° drift over decades from perturbations
// not modeled here); a/e/i/Ω/ω/M0 from published epoch-2000 osculating sets, mean
// motion n derived from a via Kepler's third law. Flagged for a numeric spot-check
// against a live ephemeris (Horizons/Swiss Eph) before relying on tight precision.
// M0 values corrected 2026-07-09: back-solved from a public osculating-elements
// snapshot (spacereference.org/JPL, epoch 2460200.5 JD) via M0 = M_cat - n*(catEpoch-J2000).
// The original M0s were off by 52-133 deg (Ceres/Pallas/Vesta) against that check; a/e/i/Om/w
// were already within catalog tolerance and untouched. Juno's original M0 was only ~5 deg off.
const ASTEROIDS = {
  Ceres:  { a: 2.7691652, e: 0.0760090, i: 10.59407, Om: 80.30553,  w: 73.59765,  M0: 8.79375,   epoch: 2451545.0 },
  Pallas: { a: 2.7733477, e: 0.2302165, i: 34.83239, Om: 172.90340, w: 310.21030, M0: 353.50007, epoch: 2451545.0 },
  Juno:   { a: 2.6683942, e: 0.2568330, i: 12.98942, Om: 169.85670, w: 248.13730, M0: 239.88000, epoch: 2451545.0 },
  Vesta:  { a: 2.3615771, e: 0.0888529, i: 7.14181,  Om: 103.84960, w: 151.70160, M0: 338.66909, epoch: 2451545.0 },
};
for (const k in ASTEROIDS) ASTEROIDS[k].n = 0.98560912 / Math.pow(ASTEROIDS[k].a, 1.5);
const ASTEROID_ORDER = ['Ceres', 'Pallas', 'Juno', 'Vesta'];

// ---------- Moon (Meeus ch.47, truncated) ----------
// [D, M, M', F, coef(1e-6 deg)]
const LR = [
  [0,0,1,0,6288774],[2,0,-1,0,1274027],[2,0,0,0,658314],[0,0,2,0,213618],[0,1,0,0,-185116],
  [0,0,0,2,-114332],[2,0,-2,0,58793],[2,-1,-1,0,57066],[2,0,1,0,53322],[2,-1,0,0,45758],
  [0,1,-1,0,-40923],[1,0,0,0,-34720],[0,1,1,0,-30383],[2,0,0,-2,15327],[0,0,1,2,-12528],
  [0,0,1,-2,10980],[4,0,-1,0,10675],[0,0,3,0,10034],[4,0,-2,0,8548],[2,1,-1,0,-7888],
  [2,1,0,0,-6766],[1,0,-1,0,-5163],[1,1,0,0,4987],[2,-1,1,0,4036],[2,0,2,0,3994],
  [4,0,0,0,3861],[2,0,-3,0,3665],[0,1,-2,0,-2689],[2,0,-1,2,-2602],[2,-1,-2,0,2390],
  [1,0,1,0,-2348],[2,-2,0,0,2236],[0,1,2,0,-2120],[0,2,0,0,-2069],[2,-2,-1,0,2048],
  [2,0,1,-2,-1773],[2,0,0,2,-1595],[4,-1,-1,0,1215],[0,0,2,2,-1110],[3,0,-1,0,-892],
  [2,1,1,0,-810],[4,-1,-2,0,759],[0,2,-1,0,-713],[2,2,-1,0,-700],[2,1,-2,0,691],
];
function moonLongitude(jdTT) {
  const T = (jdTT - 2451545) / 36525;
  const Lp = norm360(218.3164477 + 481267.88123421 * T - 0.0015786 * T * T + T * T * T / 538841 - T ** 4 / 65194000);
  const D = norm360(297.8501921 + 445267.1114034 * T - 0.0018819 * T * T + T * T * T / 545868 - T ** 4 / 113065000);
  const M = norm360(357.5291092 + 35999.0502909 * T - 0.0001536 * T * T + T * T * T / 24490000);
  const Mp = norm360(134.9633964 + 477198.8675055 * T + 0.0087414 * T * T + T * T * T / 69699 - T ** 4 / 14712000);
  const F = norm360(93.2720950 + 483202.0175233 * T - 0.0036539 * T * T - T * T * T / 3526000 + T ** 4 / 863310000);
  const A1 = norm360(119.75 + 131.849 * T), A2 = norm360(53.09 + 479264.290 * T);
  const E = 1 - 0.002516 * T - 0.0000074 * T * T;
  let sl = 0;
  for (const [d, m, mp, f, c] of LR) {
    let coef = c;
    if (m === 1 || m === -1) coef *= E; else if (m === 2 || m === -2) coef *= E * E;
    sl += coef * Math.sin((d * D + m * M + mp * Mp + f * F) * D2R);
  }
  sl += 3958 * Math.sin(A1 * D2R) + 1962 * Math.sin((Lp - F) * D2R) + 318 * Math.sin(A2 * D2R);
  return norm360(Lp + sl / 1e6);
}
// Latitude (Meeus 47.B, truncated) and distance (47.A) for 3D lunar state
const BR = [
  [0,0,0,1,5128122],[0,0,1,1,280602],[0,0,1,-1,277693],[2,0,0,-1,173237],[2,0,-1,1,55413],
  [2,0,-1,-1,46271],[2,0,0,1,32573],[0,0,2,1,17198],[2,0,1,-1,9266],[0,0,2,-1,8822],
  [2,-1,0,-1,8216],[2,0,-2,-1,4324],[2,0,1,1,4200],[2,1,0,-1,-3359],[2,-1,-1,1,2463],
  [2,-1,0,1,2211],[2,-1,-1,-1,2065],[0,1,-1,-1,-1870],[4,0,-1,-1,1828],[0,1,0,1,-1794],
  [0,0,0,3,-1749],[0,1,-1,1,-1565],[1,0,0,1,-1491],[0,1,1,1,-1475],[0,1,1,-1,-1410],
  [0,1,0,-1,-1344],[1,0,0,-1,-1335],[0,0,3,1,1107],[4,0,0,-1,1021],[4,0,-1,1,833],
];
const RR = [
  [0,0,1,0,-20905355],[2,0,-1,0,-3699111],[2,0,0,0,-2955968],[0,0,2,0,-569925],[0,1,0,0,48888],
  [0,0,0,2,-3149],[2,0,-2,0,246158],[2,-1,-1,0,-152138],[2,0,1,0,-170733],[2,-1,0,0,-204586],
  [0,1,-1,0,-129620],[1,0,0,0,108743],[0,1,1,0,104755],[2,0,0,-2,10321],[0,0,1,-2,79661],
  [4,0,-1,0,-34782],[0,0,3,0,-23210],[4,0,-2,0,-21636],[2,1,-1,0,24208],[2,1,0,0,30824],
  [1,0,-1,0,-8379],[1,1,0,0,-16675],[2,-1,1,0,-12831],[2,0,2,0,-10445],[4,0,0,0,-11650],
  [2,0,-3,0,14403],[0,1,-2,0,-7003],[2,-1,-2,0,10056],[1,0,1,0,6322],[2,-2,0,0,-9884],
];
function moonFund(jdTT) {
  const T = (jdTT - 2451545) / 36525;
  return {
    T,
    Lp: norm360(218.3164477 + 481267.88123421 * T - 0.0015786 * T * T + T * T * T / 538841 - T ** 4 / 65194000),
    D: norm360(297.8501921 + 445267.1114034 * T - 0.0018819 * T * T + T * T * T / 545868 - T ** 4 / 113065000),
    M: norm360(357.5291092 + 35999.0502909 * T - 0.0001536 * T * T + T * T * T / 24490000),
    Mp: norm360(134.9633964 + 477198.8675055 * T + 0.0087414 * T * T + T * T * T / 69699 - T ** 4 / 14712000),
    F: norm360(93.2720950 + 483202.0175233 * T - 0.0036539 * T * T - T * T * T / 3526000 + T ** 4 / 863310000),
    E: 1 - 0.002516 * T - 0.0000074 * T * T,
  };
}
function moon3D(jdTT) { // {lon, lat(deg), r(km)} of date
  const f = moonFund(jdTT);
  const lon = moonLongitude(jdTT);
  const A1 = norm360(119.75 + 131.849 * f.T), A3 = norm360(313.45 + 481266.484 * f.T);
  let sb = 0;
  for (const [d, m, mp, ff, c] of BR) {
    let coef = c;
    if (m === 1 || m === -1) coef *= f.E; else if (m === 2 || m === -2) coef *= f.E * f.E;
    sb += coef * Math.sin((d * f.D + m * f.M + mp * f.Mp + ff * f.F) * D2R);
  }
  sb += -2235 * Math.sin(f.Lp * D2R) + 382 * Math.sin(A3 * D2R) + 175 * Math.sin((A1 - f.F) * D2R)
      + 175 * Math.sin((A1 + f.F) * D2R) + 127 * Math.sin((f.Lp - f.Mp) * D2R) - 115 * Math.sin((f.Lp + f.Mp) * D2R);
  let sr = 0;
  for (const [d, m, mp, ff, c] of RR) {
    let coef = c;
    if (m === 1 || m === -1) coef *= f.E; else if (m === 2 || m === -2) coef *= f.E * f.E;
    sr += coef * Math.cos((d * f.D + m * f.M + mp * f.Mp + ff * f.F) * D2R);
  }
  return { lon, lat: sb / 1e6, r: 385000.56 + sr / 1000 };
}
function moonXYZ(jdTT) {
  const { lon, lat, r } = moon3D(jdTT);
  const cl = Math.cos(lon * D2R), sl = Math.sin(lon * D2R), cb = Math.cos(lat * D2R), sb = Math.sin(lat * D2R);
  return [r * cb * cl, r * cb * sl, r * sb];
}
// Osculating node & apogee (true Node / true Lilith) from lunar state vector
const MU_EM = 403503.24 * 86400 * 86400; // km^3/day^2, G(M_E+M_Moon)
function oscNodeApogee(jdTT) {
  const dt = 0.01;
  const r0 = moonXYZ(jdTT), rp = moonXYZ(jdTT + dt), rm = moonXYZ(jdTT - dt);
  const v = [(rp[0] - rm[0]) / (2 * dt), (rp[1] - rm[1]) / (2 * dt), (rp[2] - rm[2]) / (2 * dt)];
  const h = [r0[1] * v[2] - r0[2] * v[1], r0[2] * v[0] - r0[0] * v[2], r0[0] * v[1] - r0[1] * v[0]];
  const node = norm360(Math.atan2(h[0], -h[1]) * R2D); // ascending node: atan2(N_y,N_x), N = ẑ×h = (−h_y, h_x, 0)
  const rmag = Math.hypot(r0[0], r0[1], r0[2]);
  const vxh = [v[1] * h[2] - v[2] * h[1], v[2] * h[0] - v[0] * h[2], v[0] * h[1] - v[1] * h[0]];
  const e = [vxh[0] / MU_EM - r0[0] / rmag, vxh[1] / MU_EM - r0[1] / rmag, vxh[2] / MU_EM - r0[2] / rmag];
  const apogee = norm360(Math.atan2(-e[1], -e[0]) * R2D); // ecliptic longitude of apogee direction
  return { node, apogee };
}
function meanNode(jdTT) {
  const T = (jdTT - 2451545) / 36525;
  return norm360(125.0445479 - 1934.1362891 * T + 0.0020754 * T * T + T ** 3 / 467441);
}
function meanLilith(jdTT) { // mean lunar apogee = mean perigee + 180
  const T = (jdTT - 2451545) / 36525;
  const perigee = 83.3532465 + 4069.0137287 * T - 0.0103200 * T * T - T ** 3 / 80053;
  return norm360(perigee + 180);
}

// ---------- positions of date ----------
const BODY_ORDER = ['Sun','Moon','Mercury','Venus','Mars','Jupiter','Saturn','Uranus','Neptune','Pluto','Node','SNode','Chiron','Lilith'];
function positions(jdUT) {
  const jdTT = jdUT + deltaTdays(jdUT);
  const T = (jdTT - 2451545) / 36525;
  const prec = precessionToDate(T);
  const earth = helioXYZ(EL.Earth, T);
  const out = {};
  out.Sun = norm360(Math.atan2(-earth[1], -earth[0]) * R2D + prec);
  for (const name of ['Mercury','Venus','Mars','Jupiter','Saturn','Uranus','Neptune','Pluto']) {
    const p = helioXYZ(EL[name], T);
    out[name] = norm360(Math.atan2(p[1] - earth[1], p[0] - earth[0]) * R2D + prec);
  }
  const ch = chironXYZ(jdTT);
  out.Chiron = norm360(Math.atan2(ch[1] - earth[1], ch[0] - earth[0]) * R2D + prec);
  for (const name of ASTEROID_ORDER) {
    const p = keplerBodyXYZ(ASTEROIDS[name], jdTT);
    out[name] = norm360(Math.atan2(p[1] - earth[1], p[0] - earth[0]) * R2D + prec);
  }
  out.Moon = moonLongitude(jdTT);
  const osc = oscNodeApogee(jdTT);
  out.Node = osc.node;       // true (osculating) node
  out.SNode = norm360(osc.node + 180); // south node
  out.Lilith = osc.apogee;   // true (osculating) apogee
  out.NodeMean = meanNode(jdTT);
  out.LilithMean = meanLilith(jdTT);
  return out;
}

// ---------- 3D state, for the eclipse block ----------
// Longitude alone cannot tell an eclipse from a syzygy: that needs the Moon's LATITUDE and both
// distances (node distance, magnitude, type). These two doors exist for mundane.js and nothing else
// reads them; `positions()` stays longitude-only so no scan pays for the extra series.
function moonState(jdUT) {   // {lon, lat} deg of date, {r} km geocentric
  return moon3D(jdUT + deltaTdays(jdUT));
}
function sunState(jdUT) {    // {lon} deg of date, {r} km geocentric
  const jdTT = jdUT + deltaTdays(jdUT), T = (jdTT - 2451545) / 36525;
  const earth = helioXYZ(EL.Earth, T);
  return { lon: norm360(Math.atan2(-earth[1], -earth[0]) * R2D + precessionToDate(T)),
    r: Math.hypot(earth[0], earth[1], earth[2]) * 149597870.7 };
}

// ---------- sidereal time, angles ----------
// Single-body longitude — the scan-path evaluator. positions() computes the whole chart
// (including the expensive lunar series + osculating node) on every call; root-refinement
// loops (timespine bisects) only ever need ONE body at a jd, so this skips everything else.
// Same formulas as positions(), body for body — conformance-checked in tests/timespine.test.html.
function bodyLon(jdUT, name) {
  const jdTT = jdUT + deltaTdays(jdUT);
  const T = (jdTT - 2451545) / 36525;
  if (name === 'Moon') return moonLongitude(jdTT);
  if (name === 'Node' || name === 'SNode' || name === 'Lilith') {
    const osc = oscNodeApogee(jdTT);
    return name === 'Lilith' ? osc.apogee : name === 'SNode' ? norm360(osc.node + 180) : osc.node;
  }
  const prec = precessionToDate(T);
  const earth = helioXYZ(EL.Earth, T);
  if (name === 'Sun') return norm360(Math.atan2(-earth[1], -earth[0]) * R2D + prec);
  let p = null;
  if (EL[name]) p = helioXYZ(EL[name], T);
  else if (name === 'Chiron') p = chironXYZ(jdTT);
  else if (ASTEROIDS[name]) p = keplerBodyXYZ(ASTEROIDS[name], jdTT);
  else return undefined;
  return norm360(Math.atan2(p[1] - earth[1], p[0] - earth[0]) * R2D + prec);
}

function gmst(jdUT) {
  const T = (jdUT - 2451545) / 36525;
  return norm360(280.46061837 + 360.98564736629 * (jdUT - 2451545) + 0.000387933 * T * T - T ** 3 / 38710000);
}
function obliquity(jdUT) {
  const T = (jdUT - 2451545) / 36525;
  return 23.43929111 - 0.01300417 * T - 1.64e-7 * T * T;
}
function angles(jdUT, lat, lon) { // lon east-positive
  const ramc = norm360(gmst(jdUT) + lon);
  const eps = obliquity(jdUT) * D2R, phi = lat * D2R, ra = ramc * D2R;
  const mc = norm360(Math.atan2(Math.sin(ra), Math.cos(ra) * Math.cos(eps)) * R2D);
  const asc = norm360(Math.atan2(Math.cos(ra), -(Math.sin(ra) * Math.cos(eps) + Math.tan(phi) * Math.sin(eps))) * R2D);
  return { asc, mc, ramc };
}

// Vertex: the western intersection of the ecliptic with the prime vertical — the Ascendant
// formula evaluated at the co-latitude and the OPPOSITE meridian (RAMC of the IC, ramc+180).
// Using ramc alone yields the Antivertex, which sits ~on the Ascendant (the bug this fixes).
// Verified against a brute-force prime-vertical solve: exact match.
function vertex(jdUT, lat, lon) {
  const ramc = norm360(gmst(jdUT) + lon);
  const eps = obliquity(jdUT) * D2R, colat = (90 - lat) * D2R, ra = norm360(ramc + 180) * D2R;
  return norm360(Math.atan2(Math.cos(ra), -(Math.sin(ra) * Math.cos(eps) + Math.tan(colat) * Math.sin(eps))) * R2D);
}

// Part of Fortune (Hermetic lot): day formula asc+Moon-Sun, night formula asc+Sun-Moon.
// The other seven lots live in astrodna (an expression of a decode, not an ephemeris read).
function partOfFortune(sunLon, moonLon, ascLon, isDay) {
  return isDay ? norm360(ascLon + moonLon - sunLon) : norm360(ascLon + sunLon - moonLon);
}

// Find UT jd within [jdStart, jdStart+1.05] when local ASC == targetAsc (rising crossing)
function findAscAnchor(jdStart, targetAsc, lat, lon) {
  const f = (jd) => wrap180(angles(jd, lat, lon).asc - targetAsc);
  const step = 1 / 96; // 15 min
  let prev = f(jdStart);
  for (let t = jdStart + step; t <= jdStart + 1.02 + 1e-9; t += step) {
    const cur = f(t);
    if (prev < 0 && cur >= 0 && (cur - prev) < 180) {
      let lo = t - step, hi = t;
      for (let i = 0; i < 40; i++) {
        const mid = (lo + hi) / 2;
        if (f(mid) < 0) lo = mid; else hi = mid;
      }
      return (lo + hi) / 2;
    }
    prev = cur;
  }
  return null;
}

window.__ORBO_EPH = { norm360, wrap180, julianDay, jdToDate, ASTEROID_ORDER, BODY_ORDER, positions, bodyLon, moonState, sunState, gmst, obliquity, angles, vertex, partOfFortune, findAscAnchor };
})();
