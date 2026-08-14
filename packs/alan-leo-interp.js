// alan-leo-interp.js — resolver for the Alan Leo Progressed Ascendant decan pack (SOURCE OF TRUTH).
// Sibling to packs/interp.js, not a replacement: dark-pixie is sign/house-keyed, this corpus is
// DECAN-keyed (36 records, ~10 years each), a genuinely different shape, so it gets its own tiny
// resolver rather than being forced through readingsFor(domain, body, sign, house).
//
// The instrument loads this via packs/alan-leo-progressed-ascendant.browser.js (window.__ORBO_ALAN_LEO),
// same split as dark-pixie: this module is the readable source, the browser build embeds the pack
// data inline (small corpus, no runtime fetch needed) so the standalone export never depends on a
// fetch() the bundler can't see.

export const PACK_ID = 'alan-leo-progressed-ascendant';

// Global decan index (1-36) from a sign address (0-11) and a degree within that sign (0-30).
// Mirrors the JSON's own `global_decan` field: signIdx*3 + (which third of the sign) + 1.
export function decanForDegree(signIdx, degreeInSign) {
  const d = Math.max(0, Math.min(29.9999, degreeInSign));
  return signIdx * 3 + Math.floor(d / 10) + 1;
}

export function decanReadingFor(pack, globalDecan) {
  if (!pack || !pack.entries) return null;
  return pack.entries['progressed.ascendant.decan.' + globalDecan] || null;
}

// Alan Leo's Moon-in-sign pack (Astrology for All, Ch. XVII) — sign-keyed, the plainest shape in
// this family; a second natal source beside Dark Pixie's own natal.moon.sign.* entries, read the
// same way the progressed-ascendant decan card sits beside Dark Pixie on the progressed sheet.
export function moonSignReadingFor(pack, signName) {
  if (!pack || !pack.entries) return null;
  return pack.entries['natal.moon.sign.' + String(signName).toLowerCase()] || null;
}

export function attributionOf(pack) {
  return { name: pack.attribution, url: pack.attributionUrl || null };
}
