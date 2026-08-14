// aaf.js — parser + translation protocol for astro.com "AAF" chart databases
// (the line-based #A93 / #B93 export format). Standalone data engine — no UI, and
// deliberately NOT wired into Orbo Astrolabe.dc.html in this pass (Fable is the master
// coder). The full mapping rationale lives beside this file in
// "AAF Translation Protocol.md"; this module is that document made executable.
//
// It mirrors sfcht.js's contract: parseAAF(text) returns an array of records in the
// SAME base shape the app's roster already speaks —
//   { name, y, mo, d, h, mi, sec, tz, lat, lon, place, kind? }
//   tz  = UTC offset in hours, EAST-POSITIVE (app convention)
//   lat = degrees, NORTH-POSITIVE ; lon = degrees, EAST-POSITIVE
// — plus the AAF-specific extensions the protocol defines (calendar, jd, taxonomy,
// lmt validation, relational metadata, provenance). A record drops straight into
// chartToPerson() unchanged; the extra fields are ignored by anything that doesn't want
// them and read by everything that does.
//
// THE CANONICAL TIME IS `jd`, NOT {y,mo,d}. astro.com marks Gregorian dates with a
// trailing "g"; bare dates before the 1582-10-15 reform are Julian. The app's
// ephem.julianDay() applies the Gregorian correction unconditionally, so re-deriving a
// jd from a stored Julian {y,mo,d} would be wrong by ~10+ days. This module computes a
// calendar-aware jd up front and treats IT as the value everything downstream (astrodna's
// buildAstroDNA, transits, framing) should read. {y,mo,d,h,mi} remain for display only.

// ---------------------------------------------------------------------------
// Field decoders
// ---------------------------------------------------------------------------

// "43n20" -> +43.3333 ; "21s18" -> -21.30 (north-positive)
function parseLat(tok) {
  const m = /^\s*(\d+)([ns])(\d+)?\s*$/i.exec(tok || '');
  if (!m) return null;
  const v = parseInt(m[1], 10) + (m[3] ? parseInt(m[3], 10) / 60 : 0);
  return round4(m[2].toLowerCase() === 's' ? -v : v);
}
// "90w23" -> -90.3833 ; "0e11" -> +0.1833 (east-positive)
function parseLon(tok) {
  const m = /^\s*(\d+)([we])(\d+)?\s*$/i.exec(tok || '');
  if (!m) return null;
  const v = parseInt(m[1], 10) + (m[3] ? parseInt(m[3], 10) / 60 : 0);
  return round4(m[2].toLowerCase() === 'w' ? -v : v);
}
// "6hw00" -> -6.0 ; "0he00" -> 0 ; "2he24" -> +2.4 (east-positive UTC offset, as applied)
function parseZone(tok) {
  const m = /^\s*(\d+)h([we])(\d+)?\s*$/i.exec(tok || '');
  if (!m) return null;
  const v = parseInt(m[1], 10) + (m[3] ? parseInt(m[3], 10) / 60 : 0);
  return round4(m[2].toLowerCase() === 'w' ? -v : v);
}
// "4.8.2025" / "5.5.1577g" / "7.2.120g" -> {y,mo,d,calendar}
function parseDate(tok) {
  const t = (tok || '').trim();
  const g = /g\s*$/i.test(t);
  const m = /^(\d+)\.(\d+)\.(\d+)/.exec(t);
  if (!m) return null;
  const d = parseInt(m[1], 10), mo = parseInt(m[2], 10), y = parseInt(m[3], 10);
  // astro.com convention: trailing "g" forces (proleptic) Gregorian; otherwise the
  // 1582-10-15 reform is the boundary — before it is Julian, on/after it is Gregorian.
  const beforeReform = y < 1582 || (y === 1582 && (mo < 10 || (mo === 10 && d < 15)));
  const calendar = g ? 'gregorian' : (beforeReform ? 'julian' : 'gregorian');
  return { y, mo, d, calendar };
}
// "17:32" / "11:34:20" -> {h,mi,sec}
function parseTime(tok) {
  const m = /^\s*(\d+):(\d+)(?::(\d+))?\s*$/.exec(tok || '');
  if (!m) return { h: 12, mi: 0, sec: 0 };
  return { h: parseInt(m[1], 10), mi: parseInt(m[2], 10), sec: m[3] ? parseInt(m[3], 10) : 0 };
}

// Calendar-aware Julian Day (UT). Gregorian branch is byte-identical to ephem.julianDay();
// the Julian branch drops the century correction (B = 0). This is the one place the
// protocol diverges from the app's current jd routine, on purpose.
export function toJD(y, mo, d, h, mi, sec, utcOffset, calendar) {
  const ut = h + mi / 60 + (sec || 0) / 3600 - (utcOffset || 0);
  let Y = y, M = mo; const D = d + ut / 24;
  if (M <= 2) { Y -= 1; M += 12; }
  let B = 0;
  if (calendar !== 'julian') { const A = Math.floor(Y / 100); B = 2 - A + Math.floor(A / 4); }
  return Math.floor(365.25 * (Y + 4716)) + Math.floor(30.6001 * (M + 1)) + D + B - 1524.5;
}

// ---------------------------------------------------------------------------
// Two-tier taxonomy — kind (ontological class) then type/subtype (semantic category).
// The AAF code (m/f/e) is a hint, not the truth: the same file tags "New Moon" and a
// stadium as `e`, and "Toronto Blue Jays" once as `e` and once as `m`. So code SEEDS the
// kind and name heuristics REFINE (and may reclassify) it — recording `codeConflict`
// whenever the two disagree, rather than silently trusting either.
// ---------------------------------------------------------------------------

const FICTION = /stranger things|barbara holland|will byers|\beleven\b|\bbilly\b|lucas sinclair|mindflayer|uncle billy summers/i;
const FICTION_SOURCE = { 'stranger things': 'Stranger Things' };

function classify(name, code) {
  const n = (name || '').toLowerCase();
  const rel = [];
  let kind, type, subtype = null;

  // ---- moment-flavoured names (win even when miscoded m/f) ----
  if (/\bnew moon\b/.test(n)) { kind = 'moment'; type = 'lunation'; subtype = 'new-moon'; }
  else if (/\bfull moon\b/.test(n)) { kind = 'moment'; type = 'lunation'; subtype = 'full-moon'; }
  else if (/\breturn\b/.test(n)) {
    kind = 'moment'; type = 'return';
    subtype = /solar/.test(n) ? 'solar-return' : /nodal|node/.test(n) ? 'nodal-return'
      : /lunar|moon/.test(n) ? 'lunar-return' : 'return';
  }
  else if (/\belection\b|serection/.test(n)) { kind = 'moment'; type = 'election'; }
  else if (/\bemail\b/.test(n)) { kind = 'moment'; type = 'communication'; subtype = 'email'; }
  else if (/\btext\b|texto|scorpiotextz|reachout|reach out/.test(n)) { kind = 'moment'; type = 'communication'; subtype = 'text'; }
  else if (/retrograde|\bin (aries|taurus|gemini|cancer|leo|virgo|libra|scorpio|sagittarius|capricorn|aquarius|pisces)\b|merc|pluto in|venus retro/.test(n)
           && !/park|jays|toyota/.test(n)) { kind = 'moment'; type = 'ingress'; }
  else if (FICTION.test(n)) {
    kind = 'person'; type = 'fictional';
    for (const k in FICTION_SOURCE) if (n.includes(k)) rel.push(FICTION_SOURCE[k]);
  }
  else if (/toyota|blue jays|miller park|\bpark\b/.test(n)) {
    kind = 'person'; type = 'entity';
    subtype = /jays|park\b/.test(n) ? 'sports-team' : 'company';
  }
  // ---- code-seeded defaults ----
  else if (code === 'e') { kind = 'moment'; type = 'event'; }
  else { kind = 'person'; type = 'natal'; }

  const seededKind = code === 'e' ? 'moment' : 'person';
  const codeConflict = kind !== seededKind;
  const gender = kind === 'person' && (code === 'm' || code === 'f') ? code : null;
  return { kind, type, subtype, gender, codeConflict, relatesTo: rel };
}

// ---------------------------------------------------------------------------
// The parser
// ---------------------------------------------------------------------------

// parseAAF(text) -> record[]. Tolerant of blank lines, CRLF, and A-lines that arrive
// without their matching B-line (place-only record, no coordinates/jd).
export function parseAAF(text) {
  const lines = String(text || '').replace(/\r/g, '').split('\n');
  const out = [];
  let a = null;
  for (const line of lines) {
    if (/^#A93/i.test(line)) { a = line; continue; }
    if (/^#B93/i.test(line) && a) { out.push(buildRecord(a, line)); a = null; continue; }
    if (/^#A93/i.test(line)) a = line;
  }
  // flush a trailing A with no B
  if (a) out.push(buildRecord(a, null));
  return out;
}

// astro.com uses "#A93:*," as the row prefix; everything after is comma-separated.
function fields(line) {
  const body = line.replace(/^#[AB]93:\*?,?/i, '');
  return body.split(',').map(s => s.trim());
}

function buildRecord(aLine, bLine) {
  const A = fields(aLine);          // name, code, date, time, place...
  const name = A[0] || '';
  const code = (A[1] || '').toLowerCase();
  const dt = parseDate(A[2]) || { y: 2000, mo: 1, d: 1, calendar: 'gregorian' };
  const tm = parseTime(A[3]);
  const placeParts = A.slice(4).filter(Boolean);
  const city = placeParts[0] || '';
  const country = placeParts[1] || '';
  const region = placeParts[2] || '';
  const place = placeParts.join(', ');

  let lat = null, lon = null, tz = 0, tzRaw = '', dst = null, lmt = false;
  let lmtRecomputed = null, lmtDeltaMin = null;
  if (bLine) {
    const B = fields(bLine);        // lat, lon, zone, flag
    lat = parseLat(B[0]);
    lon = parseLon(B[1]);
    tzRaw = B[2] || '';
    tz = parseZone(B[2]) ?? 0;
    const flag = (B[3] || '').trim().toUpperCase();
    if (flag === 'L') {
      lmt = true; dst = null;
      // Validate the stated LMT against longitude/15 (the definition of local mean time).
      if (lon != null) {
        lmtRecomputed = round4(lon / 15);
        lmtDeltaMin = round2(Math.abs(lmtRecomputed - tz) * 60);
      }
    } else if (flag === '1') dst = true;
    else if (flag === '0') dst = false;
  }

  const jd = (lat != null && lon != null)
    ? toJD(dt.y, dt.mo, dt.d, tm.h, tm.mi, tm.sec, tz, dt.calendar)
    : null;

  const tax = classify(name, code);

  return {
    // base shape (identical to what chartToPerson() consumes)
    name, y: dt.y, mo: dt.mo, d: dt.d, h: tm.h, mi: tm.mi, sec: tm.sec,
    tz, lat, lon, place,
    kind: tax.kind,                 // 'person' | 'moment'
    // AAF extensions
    calendar: dt.calendar,          // 'gregorian' | 'julian'
    jd,                             // calendar-aware UT Julian Day — the canonical time
    city, region, country,
    tzRaw, dst,                     // dst: true (was on) | false (off) | null (LMT/unknown)
    lmt, lmtRecomputed, lmtDeltaMin,
    // taxonomy
    code,                           // raw 'm' | 'f' | 'e'
    gender: tax.gender,             // 'm' | 'f' | null
    type: tax.type,                 // natal | fictional | entity | event | lunation | ingress | return | election | communication
    subtype: tax.subtype,
    codeConflict: tax.codeConflict,
    relatesTo: tax.relatesTo,       // best-effort links; app resolves to roster entries
    // provenance
    raw: { a: aLine, b: bLine || null },
  };
}

// ---------------------------------------------------------------------------
// astrodna bridge — how the user wants values stored. Optional and lazy so the parser
// itself stays dependency-free; call after parsing to decorate records with the genome.
// records lacking coordinates/jd (place-only) are passed through untouched.
// ---------------------------------------------------------------------------
export async function attachAstroDNA(records) {
  const { buildAstroDNA, sequenceString } = await import('./astrodna.js');
  for (const r of records) {
    if (r.jd == null || r.lat == null || r.lon == null) continue;
    r.dna = buildAstroDNA(r.jd, r.lat, r.lon);
    r.sequence = sequenceString(r.dna);
  }
  return records;
}

function round4(x) { return Math.round(x * 1e4) / 1e4; }
function round2(x) { return Math.round(x * 100) / 100; }
