// Interpretation-pack resolver (SOURCE OF TRUTH). Data lives in *.pack.json (generated from
// astrologer CSVs). Multi-pack ready: readingsFor/hasReading take a pack; PACK_REGISTRY lists ids.
// v1 ships one active pack (dark-pixie). Do not hand-edit the .pack.json — regenerate it.
//
// The instrument loads this via the browser-global build packs/dark-pixie.browser.js (window.
// __ORBO_INTERP), NOT this ES module — same pattern as cities/aaf/ephem. Edit this file (or the
// .pack.json), then regenerate dark-pixie.browser.js. This module stays as the readable source.

export const PACK_REGISTRY = ['dark-pixie'];

// Attribution is single-source: the pack owns the name and the URL, never a literal in the DC.
// Every surface that renders pack prose must render this (the byline law, Depth Manifest §8).
export function attributionOf(pack) {
  return { name: pack.attribution, url: pack.attributionUrl || null };
}

export async function loadPack(id = 'dark-pixie') {
  const res = await fetch(new URL('./' + id + '.pack.json', import.meta.url));
  if (!res.ok) throw new Error('pack not found: ' + id);
  return res.json();
}

// Ordered readings for a body: sign reading first, then house reading, keyed by DOMAIN
// ('natal' | 'composite'). Keys are namespaced: natal.{planet}.sign.{sign} etc. The
// Ascendant ('As') carries no planet keys — its reading IS the 1st-house-in-sign entry,
// so it resolves {domain}.house.1.sign.{sign}. Missing layers are simply absent (honest
// coverage gap — e.g. composite planet×sign has no content yet).
//
// Other ingested domains (house×sign for houses 2–12, transit×house, transit×composite×house)
// live in the pack under natal.house.{n}.sign.*, transit.{planet}.house.*,
// transit.{planet}.composite.house.* — resolved by their own future readers, not this fn.
export function readingsFor(pack, domain, planet, signName, houseNum) {
  const d = String(domain || 'natal');
  const p = String(planet).toLowerCase();
  const sg = String(signName).toLowerCase();
  const out = [];
  if (p === 'as') {
    const a = pack.entries[d + '.house.1.sign.' + sg];
    if (a) out.push({ layer: 'house-in-sign', placement: a.placement, text: a.text });
    return out;
  }
  // transit-through-the-houses: a transiting planet moving through the seated chart's houses.
  // domain 'transit' → transit.{planet}.house.{n} (natal houses); 'transit.composite' →
  // transit.{planet}.composite.house.{n}. No sign layer (a transit has no natal sign).
  if (d === 'transit' || d === 'transit.composite') {
    const base = d === 'transit.composite' ? 'transit.' + p + '.composite.house.' : 'transit.' + p + '.house.';
    const t = pack.entries[base + houseNum];
    if (t) out.push({ layer: 'transit-house', placement: t.placement, text: t.text });
    return out;
  }
  const s = pack.entries[d + '.' + p + '.sign.' + sg];
  if (s) out.push({ layer: 'sign', placement: s.placement, text: s.text });
  const h = pack.entries[d + '.' + p + '.house.' + houseNum];
  if (h) out.push({ layer: 'house', placement: h.placement, text: h.text });
  return out;
}

// Coverage gate: does TAP TO ECLIPSE appear for this body?
export function hasReading(pack, domain, planet, signName, houseNum) {
  return readingsFor(pack, domain, planet, signName, houseNum).length > 0;
}

// ── The explain corpus (the FAQ / vocabulary layer) ────────────────────────
// A DIFFERENT KIND from readingsFor's placement readings: those are keyed to chart data
// (natal.mars.house.4), these are keyed to vocabulary (explain.sign.aries.k.energy). Six
// article shapes, one namespace. Every entry carries { depth, lineage, doctrine }:
//   depth    1|2|3 — an explanation inherits the depth of the thing it explains
//   lineage  required on every depth-3 entry; null otherwise
//   doctrine { rulers:'modern' } where the source text assumes modern rulership. The plate
//            is cut traditional+modern (the co-rulership law), so Orbo names the source
//            rather than silently siding with either.
// maxDepth filters to the native's current reading depth; pass 3 for everything.

export function explainKey(topic, subject, kind) {
  var p = 'explain.' + topic;
  if (subject != null && subject !== '') p += '.' + String(subject).toLowerCase();
  if (kind) p += '.' + kind;
  return p;
}
function ok(e, maxDepth) { return !!e && (maxDepth == null || e.depth <= maxDepth); }

// One section: explainFor(pack,'sign','aries','natal') / (pack,'house',4,'keywords')
export function explainFor(pack, topic, subject, kind, maxDepth) {
  var e = pack.entries[explainKey(topic, subject, kind)];
  return ok(e, maxDepth) ? e : null;
}
// Every section for a subject, in article order, filtered by depth.
export function explainAll(pack, topic, subject, maxDepth) {
  var pre = explainKey(topic, subject, null) + '.', out = [];
  for (var key in pack.entries) {
    if (key.indexOf(pre) !== 0) continue;
    var e = pack.entries[key];
    if (ok(e, maxDepth)) out.push({ key: key, entry: e });
  }
  return out;
}
// Aspect docs are keyed by article but carry the angles they cover (60 and 120 share one).
export function explainByAngle(pack, angle, maxDepth) {
  var out = [];
  for (var key in pack.entries) {
    var e = pack.entries[key];
    if (!e.angles || e.angles.indexOf(angle) < 0) continue;
    if (ok(e, maxDepth)) out.push({ key: key, entry: e });
  }
  return out;
}
// Free-text lookup for Orbo: exact subject/title hit first, then title substring, then body.
// Ranked so "scorpio" lands on Scorpio's overview, not on a sentence mentioning Scorpio.
export function explainSearch(pack, query, maxDepth, limit) {
  var q = String(query || '').toLowerCase().trim();
  if (!q) return [];
  // "4th house" / "fourth house" / "house 4" — an ordinal query names a HOUSE, not the axis it
  // sits on. Without this, "4th house" title-matches "The 4th and 10th houses: Axis of Foundation".
  var WORD = { first:1, second:2, third:3, fourth:4, fifth:5, sixth:6, seventh:7, eighth:8, ninth:9, tenth:10, eleventh:11, twelfth:12 };
  var hm = q.match(/(\d{1,2})\s*(?:st|nd|rd|th)?\s+house/) || q.match(/^house\s+(\d{1,2})$/);
  var houseN = hm ? hm[1] : null;
  if (!houseN) { var wm = q.match(/([a-z]+)\s+house/); if (wm && WORD[wm[1]]) houseN = String(WORD[wm[1]]); }
  var hits = [];
  for (var key in pack.entries) {
    var e = pack.entries[key];
    if (key.indexOf('explain.') !== 0 || !ok(e, maxDepth)) continue;
    var subj = (e.subject || '').toLowerCase(), title = (e.title || '').toLowerCase();
    var score = 0;
    if (houseN && e.topic === 'house' && String(e.subject) === houseN) score = 95;
    else if (subj === q) score = /\.(overview|natal)$/.test(key) ? 100 : 70;
    else if (title === q) score = 90;
    else if (title.indexOf(q) >= 0) score = 60;
    else if (subj && subj.indexOf(q) >= 0) score = 40;
    else if ((e.text || '').toLowerCase().indexOf(q) >= 0) score = 10;
    if (!score) continue;
    // an article's opening outranks its subsections at equal grade — "trine" should answer with
    // what a trine IS, not with "Transit Planets Sextile or Trine Natal Planets".
    if (/\.overview$/.test(key)) score += 8;
    else if (/\.natal$/.test(key)) score += 6;
    hits.push({ key: key, entry: e, score: score });
  }
  hits.sort(function (a, b) { return b.score - a.score || a.key.length - b.key.length; });
  return hits.slice(0, limit || 5);
}
export function hasExplain(pack, topic, subject, kind, maxDepth) {
  return !!explainFor(pack, topic, subject, kind, maxDepth);
}
