// dispositor.browser.js · auto-generated browser-global build of dispositor.js (no ES modules; assigns window.__ORBO_DISPOSITOR).
// Source of truth is dispositor.js. Regenerate this file if dispositor.js changes, don't hand-edit.
// Load order: after mater.browser.js (its one dependency). Independent of tympan.browser.js, but
// conventionally follows it, per specs/The Connectome Pass.md §6.
(function boot(){
if(!window.__ORBO_MATER){return void setTimeout(boot,0);}
const { RULERS, DISPOSITORS, EXALT_BY_SIGN } = window.__ORBO_MATER;
// dispositor.js · the walker: bearer, path, keeper and terminal kind for every occupant.
//
// THE SECOND MEMBER OF THE COMPILE, alongside connectome.js. Reads and records the dispositor
// wiring of ANY occupant set — natal, a mundane moment, a synchronic set, a composite. Its input
// is an OCCUPANT-TO-SIGN MAP (`{ name: signIndex, ... }`), never a sequence and never a genome:
// a synchronic placement is `midpoint(natal, sky)` per occupant, a list of longitudes reduced to
// signs by the caller, and it never passes through the sequencer. A natal chart arrives via the
// declared projection (`mater.signIndexOf` per node); every other layer arrives directly. No modes,
// no adapter per layer — one input shape for all of them. See specs/The Connectome Pass.md §3.11.
//
// TWO NODE CLASSES (§3.6). Only the seven in mater.DISPOSITORS are dispositor-capable: each has
// exactly one outgoing edge (its domicile lord), so the graph on those seven is FUNCTIONAL and
// termination is guaranteed mathematically, not by a depth cap. Everything else Orbo carries —
// Ascendant, the three outers, the nodes, Chiron, Lilith, the asteroids, the points, the lots — HAS
// a bearer and IS never a bearer: a leaf, walked forward exactly once into the seven-node subgraph.
// Getting this backwards is the one way to route Mars to Pluto or loop forever.
//
// ONE TERMINATION RULE, length names the result (§2): a chain either reaches a planet that is its
// own bearer (a fixed point — a cycle of length 1, `domicile`), or it revisits a planet already on
// its own path (a cycle of length 2, `mutual-reception`, or length 3+, `dispositor-loop`). Never
// "closed circuit". A chain that steps to a planet whose OWN sign was not supplied by the caller
// "leaves the frame" — keeper and terminalKind read null, the honest answer for an incomplete
// occupant set, never a guess.
//
// ONE TERMINATION RULE MEANS ONE TERMINAL SHAPE (v0.886). This header said from its first line that
// own sign is a cycle of length 1, and the walker then declined to register it: a domicile terminal
// produced no cycle record, so `cycles` held only pairs and loops, `keeper` was a planet NAME there
// and a cycle ID everywhere else, and every reader matching on cycle shape had to special-case the
// most common terminal in astrology. A 1-CYCLE IS A CYCLE. It is registered like any other, and
// **`keeper` is a `{kind, id}` record on every chain** — the record names its own kind, so nothing
// downstream infers a kind from the shape of a string. `terminalKind` stays beside it (it is exactly
// `keeper.kind`) because every reader already spells it that way; absence is still `null`, on both.
//
// CYCLE IDS ARE DERIVED FROM SORTED MEMBERS, never a counter — an iteration-order id makes two
// expressions of the same genome differ, which silently breaks byte-identical output. A 1-cycle's id
// is therefore just the planet's own name, which is what the old polymorphic `keeper` returned: the
// VALUE did not change, its SHAPE did, and now it is the same shape as every other terminal.
//
// RECEPTION moved here from rulers.js (its Layer 2), reshaped to sign input. Reception is NOT a
// dignity, it is a relation mediated by one: A sits where B has essential dignity, so B receives A.
// `kind` names the mediating dignity — domicile, exaltation, or mixed (A in B's domicile while B is
// in A's exaltation, or the reverse). Mutual reception BY DOMICILE is exactly the two-planet cycle
// in the dispositor graph and is not computed twice; only the exaltation and mixed cases are new
// information the graph doesn't already carry. Scoped to the traditional seven, same as before.
//
// REFUSES: the Tympan · place · time · the Ring · aspects · orbs · sect · the modern ruler table.
// Sect and the agency/light chain selections live one layer up, in connectome.js, because they need
// the Tympan. A placeless field therefore still gets a FULL seven-planet graph here, with houses
// `null` and no agency or light chain (both start from the Ascendant) — three honest absences
// rather than a mode switch. `governed` is the single place the two halves meet.
//
// rulers.js keeps its own layer untouched: degree → sign, dignity-by-sign, decans, terms, faces,
// triplicity rulership, and `lordOf`/`chartRulerOf` (Layer 1, pointwise, chart-independent). This
// file is Layer 2's replacement: a chart's graph, not a single degree's law. `rulers.disposition`,
// `rulers.lonsFromDna` and `rulers.dispositionFromDna` are deleted, not parked — dead in the app
// path, superseded by this file's sign-resolution walker.
//
// It imports the Mater and nothing else. Verified in tests/dispositor.test.html.


// ---------- the validator · one argument kind ----------
function signAddr(signIdx, who) {
  if (typeof signIdx !== 'number' || !Number.isInteger(signIdx) || signIdx < 0 || signIdx > 11) {
    throw new Error('dispositor: ' + who + ' needs a sign address 0-11, got ' + String(signIdx));
  }
  return signIdx;
}

// The seven that dispose. Everything else Orbo carries is a pendant leaf.
function isDispositorCapable(name) { return DISPOSITORS.includes(name); }

// The immediate domicile lord of an occupant's own sign — always computable from the Mater's
// table alone, whether or not that lord's own sign is known to the walker.
function bearerOf(signIdx) { return RULERS[signAddr(signIdx, 'bearerOf')]; }

// ---------- the walk: bearer, path, keeper, terminal kind — for every occupant ----------
// `signs` = { name: signIndex, ... }, any occupant set. Cycles can only ever involve the seven
// (bearer always resolves into DISPOSITORS), so leaves walk forward exactly once and then ride
// whichever planet chain they landed on.
function walk(signs) {
  const names = Object.keys(signs);
  const bearer = {};
  for (const n of names) bearer[n] = RULERS[signAddr(signs[n], 'walk: ' + n)];

  const chains = {};
  const cyclesById = new Map();
  // One registrar for all three lengths, so a fixed point cannot be recorded differently from a pair
  // by having its own branch. Returns the keeper record every chain terminates in.
  const register = (members, kind) => {
    const id = members.join('+');
    if (!cyclesById.has(id)) cyclesById.set(id, { id, members, length: members.length, kind });
    return { kind, id };
  };

  for (const start of names) {
    const path = [start];
    const seen = new Set([start]);
    let cur = start, keeper = null, terminalKind = null;
    while (true) {
      if (DISPOSITORS.includes(cur) && bearer[cur] === cur) { keeper = register([cur], 'domicile'); terminalKind = 'domicile'; break; }
      const nxt = bearer[cur];
      if (!(nxt in signs)) break; // leaves the frame: the bearer's own sign was never supplied
      if (seen.has(nxt)) {
        const at = path.indexOf(nxt);
        const members = path.slice(at).sort();
        const kind = members.length === 2 ? 'mutual-reception' : 'dispositor-loop';
        keeper = register(members, kind); terminalKind = kind;
        break;
      }
      path.push(nxt); seen.add(nxt); cur = nxt;
    }
    chains[start] = { bearer: bearer[start], path, keeper, terminalKind };
  }

  return { chains, cycles: [...cyclesById.values()] };
}

// ---------- reception: a relation mediated by a dignity, never a dignity itself ----------
// Scoped to the classical seven, the traditional dignity ladder's own domain. `signs` need only
// carry entries for the two planets being compared; a planet already home (its own bearer) mediates
// nothing that way, per the classical rule.
function receptions(signs) {
  const out = [];
  for (let i = 0; i < DISPOSITORS.length; i++) {
    for (let j = i + 1; j < DISPOSITORS.length; j++) {
      const a = DISPOSITORS[i], b = DISPOSITORS[j];
      if (!(a in signs) || !(b in signs)) continue;
      const sa = signAddr(signs[a], 'receptions: ' + a), sb = signAddr(signs[b], 'receptions: ' + b);
      if (RULERS[sa] === a || RULERS[sb] === b) continue; // a planet at home receives no one that way
      const aInDomB = RULERS[sa] === b, aInExaB = EXALT_BY_SIGN[sa] === b;
      const bInDomA = RULERS[sb] === a, bInExaA = EXALT_BY_SIGN[sb] === a;
      if (aInDomB && bInDomA) out.push({ a, b, kind: 'domicile' });
      else if (aInExaB && bInExaA) out.push({ a, b, kind: 'exaltation' });
      else if ((aInDomB && bInExaA) || (aInExaB && bInDomA)) out.push({ a, b, kind: 'mixed' });
    }
  }
  return out;
}

// ---------- cross-set · the relations BETWEEN two occupant sets (Phase 9 P4's prerequisite) ----------
// RELATION's own prep, on this file's own pattern: two maps in, the relations between them out.
// SIBLING EXPORTS, never folded inside walk(). ONE STEP ACROSS, NEVER AN ALTERNATING WALK — the same
// refusal as compositing two composites. A SAME-NAME PAIR IS NOT A CROSS RELATION (Venus rules Taurus
// in every set there is, so that fact belongs to A alone). See dispositor.js for the full header.
function crossReceptions(signsA, signsB) {
  const out = [];
  for (const a of DISPOSITORS) {
    if (!(a in signsA)) continue;
    const sa = signAddr(signsA[a], 'crossReceptions: a ' + a);
    for (const b of DISPOSITORS) {
      if (a === b || !(b in signsB)) continue;
      const sb = signAddr(signsB[b], 'crossReceptions: b ' + b);
      const aHome = RULERS[sa] === a, bHome = RULERS[sb] === b; // at home = host, never a guest
      const aInDomB = !aHome && RULERS[sa] === b, aInExaB = !aHome && EXALT_BY_SIGN[sa] === b;
      const bInDomA = !bHome && RULERS[sb] === a, bInExaA = !bHome && EXALT_BY_SIGN[sb] === a;
      const aRecd = aInDomB || aInExaB, bRecd = bInDomA || bInExaA;
      if (!aRecd && !bRecd) continue;
      const kind = (aInDomB && bInDomA) ? 'domicile'
        : (aInExaB && bInExaA) ? 'exaltation'
        : (aRecd && bRecd) ? 'mixed'
        : (aInDomB || bInDomA) ? 'domicile' : 'exaltation';
      out.push({ a, b, dir: (aRecd && bRecd) ? 'mutual' : aRecd ? 'a-in-b' : 'b-in-a', kind });
    }
  }
  return out;
}
function crossHandoffs(signsA, signsB) {
  const step = (from, to, side) => Object.keys(from).map((n) => {
    const bearer = RULERS[signAddr(from[n], 'crossHandoffs: ' + side + ' ' + n)];
    return { of: side, name: n, bearer, lands: (bearer in to) ? to[bearer] : null };
  });
  return [...step(signsA, signsB, 'a'), ...step(signsB, signsA, 'b')];
}

// ---------- the one-call convenience: everything a placeless field can have ----------
function dispose(signs) {
  const w = walk(signs);
  return { chains: w.chains, cycles: w.cycles, receptions: receptions(signs) };
}
// the same convenience for a pair. Two maps, two directions, one call.
function crossDispose(signsA, signsB) {
  return { handoffs: crossHandoffs(signsA, signsB), receptions: crossReceptions(signsA, signsB) };
}

window.__ORBO_DISPOSITOR = { isDispositorCapable, bearerOf, walk, receptions, dispose, crossReceptions, crossHandoffs, crossDispose };
})();
