// alan-leo-aspects-interp.js — resolver for Alan Leo's progressed-aspect chapters (Ch. XIII Solar
// Aspects, and — as they're ingested — Ch. XIV Mutual Aspects, Ch. XV Lunar Aspects, Ch. XVI
// Directions). Sibling to alan-leo-interp.js (which resolves the decan-keyed Progressed Ascendant
// chapter): a genuinely different key shape, so a genuinely different tiny resolver.
//
// One pack per chapter (packs/alan-leo-{chapter}.pack.json), all sharing the SAME entry key shape:
// 'progressed.aspect.{moverBody}.{targetBody}.{aspectName}'. The reader tries whichever chapter
// packs are loaded and whichever body ordering applies — the relation is geometrically mutual
// (progressed-aspects.js's own law), so "progressed Mars square natal Sun" may be Ch. XIV's own
// entry even though a caller reading it from the Sun's side would ask in the other order.

export function aspectReadingFor(pack, moverBody, targetBody, aspectName) {
  if (!pack || !pack.entries) return null;
  return pack.entries['progressed.aspect.' + moverBody + '.' + targetBody + '.' + aspectName] || null;
}

// Ch. XVIII (Transits over Sun, Moon, Planets) — an unqualified "transit" in Leo's own text is a
// conjunction; the pack has no aspect dimension at all (conjunction only), so this resolver takes
// no angle argument. Covers every geometry a conjunction can occur between: live sky over natal,
// live sky over a progressed point, OR (Leo's own text: "transits over the progressed Sun or Moon")
// a progressed body over natal — same transiting_body/transited_point key regardless of which
// chart supplied which side; the reading is about the CONTACT, not which engine produced it.
export function transitReadingFor(pack, transitingBody, transitedPoint) {
  if (!pack || !pack.entries) return null;
  return pack.entries['transit.over.' + transitingBody + '.' + transitedPoint] || null;
}

// Ch. XIX (Transits Through Houses) — a body's DWELLING in a house, not a discrete hit. Two shapes
// per transiting body: a house-specific delineation (most bodies, all twelve houses) and a
// general per-body rule (Leo declines a house table for Neptune beyond the angles, and gives Mars/
// Jupiter/Saturn/Uranus a general rule ALONGSIDE their house table — read both, show whichever the
// caller wants). Doctrine (agreed with the user 2026-08-11): a progressed body's real, continuous
// motion through a natal house is the SAME kind of fact as a live-sky body's — 'progressed transits
// are transits' — so this resolver takes no opinion on which engine supplied houseNumber; it is
// called from both the live-sky single-body sheet (_sheetData) and the progressed-body reader
// (_progOccMap's natal-frame housing) alike.
export function houseTransitReadingFor(pack, transitingBody, houseNumber) {
  if (!pack || !pack.entries) return null;
  return pack.entries['transit.house.' + transitingBody + '.' + houseNumber] || null;
}
export function houseTransitGeneralFor(pack, transitingBody) {
  if (!pack || !pack.entries) return null;
  return pack.entries['transit.house.' + transitingBody + '.general'] || null;
}

export function attributionOf(pack) {
  return { name: pack.attribution, url: pack.attributionUrl || null };
}
