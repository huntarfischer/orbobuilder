// luna.browser.js — auto-generated browser-global build of luna.js (no ES modules; assigns window.__ORBO_LUNA).
// Source of truth is luna.js — regenerate this file if luna.js changes, don't hand-edit.
// Load order: after loom.browser.js.
(function boot(){
// Bundle-safety: inlined blob scripts don't preserve <script> order, so wait for deps
// (see CLAUDE.md — browser-build-only guard, no analog in the ES-module source).
if(!window.__ORBO_FRAMING || !window.__ORBO_LOOM){return void setTimeout(boot,0);}
const { floorTargets, contactTargets, synchronicTargets } = window.__ORBO_FRAMING;
const { scanTargets, decorate } = window.__ORBO_LOOM;
// luna.js — Phase 5 · S2 · the lunar module.
//
// The Moon is a CARDINALITY problem, not a difficulty problem. Over one century her sign ingresses
// alone are about 16,000 rows, her mutual aspects about 100,000, her contacts to a natal chart
// another 150,000, and her synchronic contacts the same again. Everything else in all three layers put
// together is about 50,000. She is also the most LOCAL body a reader ever wants: nobody asks for the
// Moon in 2079, they ask for the Moon this week.
//
// So she is a WINDOWED GENERATOR, never a materialised table. Give it a window, it produces her
// rows, memoised per window and discarded under pressure. It runs independently of the engrave build
// and is always available, including before fertilization.
//
// Two lunar exceptions DO materialise, and they are not here: the syzygies and her sign ingresses on
// the floor, and her flips and synchronic ingresses on the weave, because those are sparse and
// structural and must be scrubbable end to end. This file is her DENSE kinds: mutual aspects, natal
// contacts, synchronic contacts. The moment any of them is materialised anywhere, the table grows by
// an order of magnitude.
//
// There is no second scanner. Her targets are the same three target sets, cut to the rows that touch
// her, run through the one scanner in loom.js.

const LUNA_KINDS = ['ingress', 'syzygy', 'mutual', 'contact', 'synchronic'];
// Windows past this are refused rather than silently truncated: a reader asking for a decade of her
// mutual aspects is asking for the thing this module exists to prevent. Callers window.
const MAX_SPAN = { ingress: 3700, syzygy: 3700, mutual: 400, contact: 200, synchronic: 200 };
const MEMO_CAP = 24;
const memo = new Map();
function clearLuna() { memo.clear(); }

const touchesMoon = (t) => t.body === 'Moon' || t.other === 'Moon';

function lunaTargets(kind, natal, opts = {}) {
  const aspects = opts.aspects || [0, 60, 90, 120, 180];
  if (kind === 'ingress') return floorTargets({ aspects }).filter((t) => t.body === 'Moon' && t.kind === 'ingress');
  if (kind === 'syzygy') return floorTargets({ aspects }).filter((t) => t.kind === 'syzygy');
  if (kind === 'mutual') return floorTargets({ aspects }).filter((t) => touchesMoon(t) && t.kind === 'aspect');
  if (kind === 'contact') return contactTargets(natal, { aspects, bodies: ['Moon'] });
  if (kind === 'synchronic') return synchronicTargets(natal, { aspects }).filter((t) => touchesMoon(t) && t.kind === 'aspect');
  throw new Error('unknown lunar kind: ' + kind);
}

// spec: { kind, jdStart, jdEnd, natal, probe, bodyProbe, aspects, natalOrb }
// Rows come back in the loom's record shape, so a lunar row and a materialised row read alike and
// one ICS carries both. `layer` is still provenance: her mutual aspects are floor, her natal
// contacts are contact, her synchronic contacts are synchronic.
function lunaWindow(spec) {
  const kind = spec.kind, natal = spec.natal || null;
  const span = spec.jdEnd - spec.jdStart;
  if (!(span > 0)) return [];
  const cap = MAX_SPAN[kind] || 200;
  const jdEnd = span > cap ? spec.jdStart + cap : spec.jdEnd;
  const key = [kind, spec.jdStart.toFixed(4), jdEnd.toFixed(4), (spec.aspects || []).join('+'),
    natal ? natal.jd.toFixed(5) : '-', spec.natalOrb || 6].join('|');
  if (memo.has(key)) { const v = memo.get(key); memo.delete(key); memo.set(key, v); return v; }
  const targets = lunaTargets(kind, natal, spec);
  const roots = scanTargets({ targets, jdStart: spec.jdStart, jdEnd, probe: spec.probe, bodyProbe: spec.bodyProbe });
  const rows = roots.map((r) => decorate(r, { probe: spec.probe, natal, natalOrb: spec.natalOrb }));
  memo.set(key, rows);
  while (memo.size > MEMO_CAP) memo.delete(memo.keys().next().value);   // oldest out under pressure
  return rows;
}

// THE SWITCH (Phase 5 §5, from the 14-chart review). The Moon is not the moving light in a still
// set, she is the SWITCH. When a group of placements is parked within a few degrees of itself, the
// instant she reaches one member she reaches all of them, and the whole configuration lights and
// goes dark at once. A row that says "Moon trine Mercury" is under-reporting the event.
//
// So her rows are GROUPED: contacts whose exact times fall inside one span, and whose other ends sit
// inside one cluster, are one event with a members list. That is why the synchronic chart reads as a
// mundane chart: standing structure, its government, and the fast bodies that switch it on.
function switchGroups(rows, opts = {}) {
  const within = opts.within != null ? opts.within : 0.5;     // days between members of one pass
  // A GROUP IS ONE PASS, NOT A CHAIN. Without a total span the gap rule daisy-chains: each contact
  // lands inside twelve hours of the last one and a group grows across three days and a whole sign,
  // which is her ordinary motion being reported as one configuration lighting. A second body cannot
  // appear twice for the same reason.
  const maxSpan = opts.maxSpan != null ? opts.maxSpan : 1.2;
  const out = [], sorted = rows.slice().sort((a, b) => a.jd - b.jd);
  let cur = null;
  for (const r of sorted) {
    const other = r.body === 'Moon' ? r.other : r.body;
    if (cur && r.jd - cur.last <= within && r.jd - cur.jd <= maxSpan && !cur.seen.has(other)) {
      cur.seen.add(other);
      cur.members.push({ body: other, angle: r.angle, jd: r.jd, name: r.name });
      cur.last = r.jd; cur.exit = Math.max(cur.exit, r.exit != null ? r.exit : r.jd);
      continue;
    }
    if (cur) out.push(cur);
    cur = { layer: r.layer, kind: 'switch', body: 'Moon', jd: r.jd, last: r.jd, seen: new Set([other]),
      enter: r.enter != null ? r.enter : r.jd, exit: r.exit != null ? r.exit : r.jd,
      members: [{ body: other, angle: r.angle, jd: r.jd, name: r.name }] };
  }
  if (cur) out.push(cur);
  // a group of one is not a switch, it is a contact: hand it back unchanged
  return out.map((g) => {
    if (g.members.length < 2) return sorted.find((r) => r.jd === g.jd);
    delete g.seen;
    return g;
  });
}

window.__ORBO_LUNA = { LUNA_KINDS, MAX_SPAN, clearLuna, lunaTargets, lunaWindow, switchGroups };
})();
