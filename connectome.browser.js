// connectome.browser.js · auto-generated browser-global build of connectome.js (no ES modules; assigns window.__ORBO_CONNECTOME).
// Source of truth is connectome.js. Regenerate this file if connectome.js changes, don't hand-edit.
// Load order: after mater.browser.js, tympan.browser.js and dispositor.browser.js (its three dependencies).
(function boot(){
if(!window.__ORBO_MATER||!window.__ORBO_TYMPAN||!window.__ORBO_DISPOSITOR){return void setTimeout(boot,0);}
const { DISPOSITORS, RULES_SIGNS, dignityOfSign } = window.__ORBO_MATER;
const { houseOfSign, signOfHouse, rulerOfHouse, coRulerOfSign, housesRuledBy, housesCoRuledBy, frameOf, MODERNS } = window.__ORBO_TYMPAN;
const { walk, receptions, isDispositorCapable, bearerOf } = window.__ORBO_DISPOSITOR;

// ---------- the validators · one per argument kind ----------
function signAddr(signIdx, who) {
  if (typeof signIdx !== 'number' || !Number.isInteger(signIdx) || signIdx < 0 || signIdx > 11) {
    throw new Error('connectome: ' + who + ' needs a sign address 0-11, got ' + String(signIdx));
  }
  return signIdx;
}
function ascOrNull(ascSignIdx, who) {
  if (ascSignIdx === null || ascSignIdx === undefined) return null;
  return signAddr(ascSignIdx, who);
}
function sectOrNull(sect) {
  if (sect === null || sect === undefined) return null;
  if (typeof sect !== 'boolean') throw new Error('connectome: sect needs true, false or null, got ' + String(sect));
  return sect;
}
// Validate the STATE before reducing it (the mechanical trap: 720 % 360 is 0 and silently reads row
// 0). A malformed sign throws here rather than folding.
function occupantMap(occupants, who) {
  if (!occupants || typeof occupants !== 'object') throw new Error('connectome: ' + who + ' must be a name-to-sign map');
  const out = {};
  for (const name of Object.keys(occupants)) out[name] = signAddr(occupants[name], who + '.' + name);
  return out;
}

// ---------- canonical order ----------
// Mirrors astrodna.NODE_ORDER (Ascendant, Moon, Sun, Mercury...Node) plus the slow extras named in
// §3.5 (Chiron, Lilith), WITHOUT importing astrodna.js — the Connectome takes an occupant map, never
// a genome, and must not pull in the ephemeris chain. Any occupant name outside this list (an
// asteroid, a point) still gets a stable slot, sorted alphabetically after the named set, so no
// caller's occupant choice is ever silently dropped or reordered by insertion accident.
const CANONICAL_ORDER = Object.freeze(['Ascendant', 'Moon', 'Sun', 'Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune', 'Pluto', 'Node', 'Chiron', 'Lilith']);
function orderedNames(occ) {
  const known = CANONICAL_ORDER.filter((n) => n in occ);
  const rest = Object.keys(occ).filter((n) => !CANONICAL_ORDER.includes(n)).sort();
  return known.concat(rest);
}

// ---------- the frame vector · the Expression's cache key (§3.2), never the genome ----------
function frameVector(occ, asc, sect) {
  const names = orderedNames(occ);
  const ascPart = asc == null ? 'x' : String(asc);
  const sectPart = sect == null ? 'x' : (sect ? '1' : '0');
  return ascPart + '|' + names.map((n) => n + ':' + occ[n]).join(',') + '|' + sectPart;
}

// ---------- the persistence key (§3.8) · frame vector x doctrine x codec, fertKey's own shape.
// Natal and favorited-chart Expressions are the only ones ever handed to a store; a moment or a
// sky reading never calls this. CODEC bumps only when the stored shape itself changes.
//
// TWO FORMS, ONE BUILDER. `connKey(expression, doctrineKey)` is the primary: the Expression carries
// its own frame vector on `metadata.frameKey`, so a holder of one never re-derives the key out of the
// tables (which is what the DC did until v0.886, and it is a second projection of §3.11's one).
// `connKey(occupants, ascSignIdx, sect, doctrineKey)` is the pre-compile form, for a caller that wants
// to look in the store BEFORE it compiles. Both build the string here and nowhere else.
// CODEC 2 (v0.886): `keeper` became a {kind, id} record, so every stored row changed shape. CODEC 3
// (v0.887): `indexes` gained `descendantsByPlanet`, which is the same kind of change and gets the same
// treatment rather than an exception for being additive — a hydrated Expression missing an index a
// reader now expects is exactly the stale artifact the key discipline exists to prevent. A filed
// Expression misses and recompiles in microseconds; nothing else in the app is keyed on this. ----------
const CODEC = 3;
function keyOf(frameKey, doctrineKey) { return 'c' + CODEC + '|' + frameKey + '|' + (doctrineKey || ''); }
function connKey(a, b, c, d) {
  if (a && a.metadata && typeof a.metadata.frameKey === 'string') return keyOf(a.metadata.frameKey, b);
  return keyOf(frameVector(a, b, c), d);
}

// ---------- the house-routing graph · the twin of the planet graph, built here ----------
// destOf(house) -> the house the ruling planet currently occupies, or null if that planet's own
// placement was never supplied. Same math as dispositor.walk, own vocabulary (see header): a fixed
// point is an OWN-HOUSE, a 2-cycle a HOUSE EXCHANGE, 3-or-more a ROUTING LOOP.
function houseDestOf(house, asc, occ) {
  const ruler = rulerOfHouse(house, asc);
  const rulerSign = occ[ruler];
  return rulerSign == null ? null : houseOfSign(rulerSign, asc);
}
function walkHouses(destOf) {
  const chains = {}; const cyclesById = new Map();
  // The planet graph's own registrar, in the house graph's vocabulary: an own-house is a cycle of
  // length 1 and is REGISTERED like any other, so no reader special-cases a lord sitting in the house
  // it rules (v0.886).
  const register = (members, kind) => {
    const id = members.join('+');
    if (!cyclesById.has(id)) cyclesById.set(id, { id, members, length: members.length, kind });
    return { kind, id };
  };
  for (let start = 1; start <= 12; start++) {
    const path = [start]; const seen = new Set([start]);
    let cur = start, keeper = null, terminalKind = null;
    while (true) {
      const nxt = destOf(cur);
      if (nxt === cur) { keeper = register([cur], 'own-house'); terminalKind = 'own-house'; break; }
      if (nxt == null) break; // the ruler's own placement leaves the frame
      if (seen.has(nxt)) {
        const at = path.indexOf(nxt);
        const members = path.slice(at).sort((a, b) => a - b);
        const kind = members.length === 2 ? 'house-exchange' : 'routing-loop';
        keeper = register(members, kind); terminalKind = kind;
        break;
      }
      path.push(nxt); seen.add(nxt); cur = nxt;
    }
    chains[start] = Object.freeze({ start, path: Object.freeze(path), keeper: keeper && Object.freeze(keeper), terminalKind });
  }
  return { chains, cycles: [...cyclesById.values()].map((c) => Object.freeze(c)) };
}

// ---------- tables ----------
function buildPlanetTable(occ, asc, names, w, recs) {
  const receivedBy = {};
  for (const r of recs) {
    (receivedBy[r.a] ||= []).push({ with: r.b, kind: r.kind });
    (receivedBy[r.b] ||= []).push({ with: r.a, kind: r.kind });
  }
  return names.map((name) => {
    const sign = occ[name];
    const chain = w.chains[name];
    const capable = isDispositorCapable(name);
    return Object.freeze({
      name, sign,
      house: asc == null ? null : houseOfSign(sign, asc),
      // domicile · exaltation · detriment · fall · null. A reader's word for null is 'peregrine';
      // this stays the Mater's own vocabulary rather than relabeling at the compiler.
      dignity: dignityOfSign(name, sign),
      dispositorCapable: capable,
      bearer: chain.bearer,
      path: Object.freeze(chain.path.slice()),
      keeper: chain.keeper && Object.freeze(chain.keeper),
      terminalKind: chain.terminalKind,
      receptions: Object.freeze(receivedBy[name] || []),
      rulesSigns: capable ? RULES_SIGNS[name] : Object.freeze([]),
      rulesHouses: capable && asc != null ? housesRuledBy(name, asc) : null,
      coRulesHouses: (capable || MODERNS.includes(name)) && asc != null ? housesCoRuledBy(name, asc) : null,
    });
  });
}
function buildHouseTable(asc, occ) {
  if (asc == null) return null;
  const out = [];
  for (let h = 1; h <= 12; h++) {
    const sign = signOfHouse(h, asc);
    out.push(Object.freeze({
      house: h, sign,
      ruler: rulerOfHouse(h, asc),
      coRuler: coRulerOfSign(sign),
      destinationHouse: houseDestOf(h, asc, occ),
    }));
  }
  return Object.freeze(out);
}

// THE SIX KEPT MEASUREMENTS ARE INDEX READS, not a metrics bag (§5.4 kept six and named none of them
// on the Expression, which read as unfinished work). Five collapse into `indexes` exactly as §3.10
// predicts: path length is `chains[p].path.length` · inbound degree is
// `planetsDisposedByPlanet[p].length` · cycle membership is `cycleByPlanet[p]` · fixed-point
// membership is `cycleByPlanet[p].length === 1` (free since a 1-cycle became a registered cycle) ·
// house routing load is `housesRoutingToHouse[h].length`. The sixth, DESCENDANT COUNT, was the one
// that needed a walk, so it became a row: `descendantsByPlanet`. The unnamed `metrics` bag stays
// dropped, and the CUT four stay cut — outbound degree (always 1, in every chart, forever), density
// (a lossy re-encoding of how many planets are in domicile), diameter (already max distanceToCycle)
// and centrality (a ranking with a mathematical alibi), the last asserted by grep in the test.
//
// ---------- indexes · the whole point, a lookup rather than a re-walk ----------
function buildIndexes(planetTable, houseTable, chains, cycles, asc) {
  const planetByName = {}; for (const p of planetTable) planetByName[p.name] = p;
  const houseByNumber = {}; if (houseTable) for (const h of houseTable) houseByNumber[h.house] = h;
  const chainByPlanet = {}; for (const c of chains) chainByPlanet[c.start] = c;
  const cycleByPlanet = {}; for (const c of cycles) for (const m of c.members) cycleByPlanet[m] = c;
  const planetsDisposedByPlanet = {};
  for (const p of planetTable) (planetsDisposedByPlanet[p.bearer] ||= []).push(p.name);
  for (const k of Object.keys(planetsDisposedByPlanet)) planetsDisposedByPlanet[k] = Object.freeze(planetsDisposedByPlanet[k]);
  // TRANSITIVE dependents, which `planetsDisposedByPlanet` is not: that one is INBOUND DEGREE (who
  // answers to this planet immediately), and "how much of the chart routes through Saturn" is a
  // different question that a reader would otherwise have to walk every path to answer. §3.10's rule
  // fired here and nowhere else in the six kept measurements: if a pattern requires derivation, a
  // table is missing. Free at build, since every path is already in hand.
  const descendantsByPlanet = {};
  for (const c of chains) for (const n of c.path.slice(1)) (descendantsByPlanet[n] ||= []).push(c.start);
  for (const k of Object.keys(descendantsByPlanet)) descendantsByPlanet[k] = Object.freeze(descendantsByPlanet[k]);
  // A direct Tympan passthrough for all seven, independent of who is actually placed — the reverse
  // governance index exists whether or not that planet's own sign was supplied.
  const housesRuledByPlanet = {};
  if (asc != null) for (const p of DISPOSITORS) housesRuledByPlanet[p] = housesRuledBy(p, asc);
  const housesRoutingToHouse = {};
  if (houseTable) {
    for (let h = 1; h <= 12; h++) housesRoutingToHouse[h] = [];
    for (const h of houseTable) if (h.destinationHouse != null) housesRoutingToHouse[h.destinationHouse].push(h.house);
    for (let h = 1; h <= 12; h++) housesRoutingToHouse[h] = Object.freeze(housesRoutingToHouse[h]);
  }
  return Object.freeze({
    planetByName: Object.freeze(planetByName),
    houseByNumber: houseTable ? Object.freeze(houseByNumber) : null,
    chainByPlanet: Object.freeze(chainByPlanet),
    cycleByPlanet: Object.freeze(cycleByPlanet),
    planetsDisposedByPlanet: Object.freeze(planetsDisposedByPlanet),
    descendantsByPlanet: Object.freeze(descendantsByPlanet),
    housesRuledByPlanet: asc != null ? Object.freeze(housesRuledByPlanet) : null,
    housesRoutingToHouse: houseTable ? Object.freeze(housesRoutingToHouse) : null,
  });
}

// ---------- topology · a label, never a key ----------
function topologyLabel(chainList) {
  const counts = {};
  for (const c of chainList) { const k = c.terminalKind || 'open'; counts[k] = (counts[k] || 0) + 1; }
  return Object.keys(counts).sort().map((k) => k + counts[k]).join('');
}

// ---------- the compile · normalize already ran; this is graphs -> tables -> topology -> indexes ----------
function compile(occ, asc, sect) {
  const names = orderedNames(occ);
  const w = walk(occ);
  const recs = receptions(occ);
  const planetTable = Object.freeze(buildPlanetTable(occ, asc, names, w, recs));
  const houseWalk = asc == null ? null : walkHouses((h) => houseDestOf(h, asc, occ));
  const houseTable = buildHouseTable(asc, occ);
  const chains = Object.freeze(planetTable.map((p) => Object.freeze({ start: p.name, bearer: p.bearer, path: p.path, keeper: p.keeper, terminalKind: p.terminalKind })));
  const cycles = Object.freeze(w.cycles.map((c) => Object.freeze(c)));
  const houseChains = houseWalk ? Object.freeze(Object.values(houseWalk.chains)) : null;
  const houseCycles = houseWalk ? Object.freeze(houseWalk.cycles) : null;
  const indexes = buildIndexes(planetTable, houseTable, chains, cycles, asc);
  const agency = asc == null ? null : bearerOf(asc);
  const light = sect == null ? null : (sect ? 'Sun' : 'Moon');
  const agencyChain = agency ? indexes.chainByPlanet[agency] || null : null;
  const lightChain = light ? indexes.chainByPlanet[light] || null : null;
  const charged = agencyChain && lightChain ? (agencyChain.keeper != null && lightChain.keeper != null && agencyChain.keeper.id === lightChain.keeper.id) : null;
  const topologyKey = 'p:' + topologyLabel(chains) + '|h:' + (houseChains ? topologyLabel(houseChains) : 'x');
  return Object.freeze({
    planetTable, houseTable, chains, cycles, houseChains, houseCycles,
    receptions: Object.freeze(recs.map((r) => Object.freeze(r))),
    agency, light, charged,
    frame: asc == null ? null : frameOf(asc),
    indexes, topologyKey,
  });
}

// ---------- the frame-vector memo (§3.2/§3.8) · so a scrubbed year of genome samples that keep
// landing on the same signs costs one compile, not thousands. Metadata is NOT part of the key: a
// memo hit still gets its OWN source/timestamp/stateKey, never the first caller's. ----------
const MEMO_CAP = 500;
const _memo = new Map();
function clearExpressionMemo() { _memo.clear(); }

// ---------- the one entry point ----------
function express(occupants, ascSignIdx, sect, meta) {
  const occ = occupantMap(occupants, 'occupants');
  const asc = ascOrNull(ascSignIdx, 'ascSignIdx');
  const sc = sectOrNull(sect);
  const key = frameVector(occ, asc, sc);
  let compiled = _memo.get(key);
  if (!compiled) {
    compiled = compile(occ, asc, sc);
    if (_memo.size >= MEMO_CAP) _memo.delete(_memo.keys().next().value);
    _memo.set(key, compiled);
  }
  const { topologyKey, ...rest } = compiled;
  const metadata = Object.freeze({
    source: (meta && meta.source != null) ? meta.source : null,
    timestamp: (meta && meta.timestamp != null) ? meta.timestamp : Date.now(),
    stateKey: (meta && meta.stateKey != null) ? meta.stateKey : null,
    // the key this Expression was memoized under, published so no holder derives it a second way
    frameKey: key,
    topologyKey,
  });
  return Object.freeze(Object.assign({}, rest, { metadata }));
}

// ---------- the load-time self-check ----------
(function stamp() {
  const who = 'connectome: ';
  if (new Set(CANONICAL_ORDER).size !== CANONICAL_ORDER.length) throw new Error(who + 'CANONICAL_ORDER has a duplicate');
  const home = { Ascendant: 0, Sun: 4, Moon: 3, Mercury: 2, Venus: 1, Mars: 0, Jupiter: 8, Saturn: 9 };
  const e = express(home, 0, true, { source: 'selftest' });
  if (e.planetTable.length !== Object.keys(home).length) throw new Error(who + 'self-test: planetTable length mismatch');
  if (!e.houseTable || e.houseTable.length !== 12) throw new Error(who + 'self-test: houseTable is not twelve houses');
  if (e.agency == null) throw new Error(who + 'self-test: agency should resolve for a full frame');
  if (!Object.isFrozen(e) || !Object.isFrozen(e.planetTable)) throw new Error(who + 'self-test: Expression is not frozen');
  if (e.metadata.frameKey !== frameVector(home, 0, true)) throw new Error(who + 'self-test: the published frameKey is not the memo key');
  if (connKey(e, 'x') !== connKey(home, 0, true, 'x')) throw new Error(who + 'self-test: the two key forms disagree');
  const mars = e.indexes.planetByName.Mars;
  if (!mars.keeper || mars.keeper.kind !== 'domicile' || !e.indexes.cycleByPlanet.Mars) throw new Error(who + 'self-test: a fixed point must be a registered cycle of length 1');
  clearExpressionMemo(); // don't let the self-test's entry linger in the real memo
})();

window.__ORBO_CONNECTOME = { express, frameVector, clearExpressionMemo, CANONICAL_ORDER, CODEC, connKey };
})();
