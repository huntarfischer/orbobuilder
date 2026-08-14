// ring.browser.js — auto-generated browser-global build of ring.js (no ES modules; assigns window.__ORBO_RING).
// Source of truth is ring.js — regenerate this file if ring.js changes, don't hand-edit.
// Load order: FIRST. The Ring is the floor and imports nothing, so it has no dependency guard.
(function boot(){
// ring.js — the Ring: the database relationship of any given degree to any other given degree.
//
// A FLAT CIRCLE, AND THAT IS THE WHOLE OF IT. The Ring holds no occupants, so it never knows where
// the Moon is. It holds no meanings, so it knows nothing of signs, elements, decans, terms, faces or
// rulers. It holds no orb. "What is where" is the DNA and the sky; "what it means" is the readers;
// the Ring is the relation both consult. It imports NOTHING, because it is the floor.
//
// A brass astrolabe contains no ephemeris: the plate, the rete and the limb ARE engraved tables, and
// the historical object computed nothing. timespine.js's constitution names three tiers
// (MATERIALIZED because expensive, DERIVED AT READ because cheap, REFUSED because it floods the
// table). This is a fourth the app has never had: INHERENT. No arguments, no time, no native, no
// place. True before the app runs.
//
// THE ELEVEN MARKS ARE THE DIE, NOT THE ARTIFACT. The full table is stamped into typed arrays at
// load, once, before anything asks, so readers point at a table instead of computing per call and it
// is byte-identical for every reader by construction rather than by download. You ship the cut
// plate, not the maker's rule.
//
// EVERYTHING IN ORBO EXISTS ON THE RING. Natal, transiting, synchronic, composite: it never leaves.
// A synchronic Mars at 0 Aries IS at 0 Aries, means what that state means, and squares anything at
// 90 and 270. There is no synchronic space, so there is nothing to pull back from. The only
// difference between layers is the occupant's SPEED (natal 0, transiting v, synchronic v/2), which
// is time and belongs to the scanner, never here.
//
// AUTHORITY: tests/fixtures/aspect-atlas.md — 720 states, 14,400 targets, human-auditable. It is a
// FIXTURE, never a runtime asset: the bundler follows only HTML src/href, so a fetch() of a .md
// ships missing from the standalone while the served preview looks fine (standalone-export law).

// The floor imports nothing, so it carries its own.
const norm360 = (d) => ((d % 360) + 360) % 360;

// The eleven marks, ascending. SEPTILES ARE EXCLUDED (51.4286, 102.8571, 154.2857) — deliberately,
// not overlooked. Every mark here is a WHOLE NUMBER OF DEGREES (each is 360*k/n for an n that divides
// 360, WITH n <= 12 — unbounded, n=360 admits any integer and the claim says nothing), so every
// target is a whole degree and the table is a perfect lattice: exactness is structural
// rather than something a comment defends. 7 does not divide 360, so a septile is 51.4286..., which
// would put marks between states and reintroduce half a degree of quantization everywhere.
// NOTE: this is not the same as each mark dividing 360 — 135, 144 and 150 do not, and do not need to.
const MARKS = Object.freeze([0, 30, 45, 60, 72, 90, 120, 135, 144, 150, 180]);
const DEGREES = 360;
const STATES = 720;
const TIE = 'lower';
// The unit, and it is INHERENT like everything else here: 3600 arcseconds to a degree and 1,296,000
// to a circle are true before the app runs. THE MODULUS IS ALWAYS A NAMED CONSTANT FROM HERE ON. The
// coarse space cost ckState precisely because 360 and 720 were typed as literals all over it, and
// `720 % 360` is 0, so an out-of-range state silently read row 0. At this scale the same class of
// miss reads a position 360 degrees away with nothing thrown, so the guard is the whole risk.
const ARCSEC = 60 * 60;
const ARCSECONDS = DEGREES * ARCSEC;   // 1,296,000 · one circle, exactly
const FINE_STATES = ARCSECONDS * 2;    // 2,592,000 · direct half, retrograde half

const NM = MARKS.length;
const MARK_INDEX = new Map(MARKS.map((a, i) => [a, i]));

// ---------- the three validators ----------
// ONE validator per input kind, applied at EVERY public entry point. The previous pass hardened
// targetDegree in place and left its siblings indexing the typed arrays raw, which is how relation()
// came to return undefined: a fractional index into an Int8Array is undefined, `undefined < 0` is
// false, so it fell through to MARKS[undefined]. A contract enforced by one function out of six is
// not a contract.
const ckState = (s, who) => {
  // Validate the STATE, not the degree it reduces to: 720 % 360 is 0, so a degree check waves an
  // out-of-range state through and silently reads row 0.
  if (!Number.isInteger(s) || s < 0 || s >= STATES) throw new RangeError('ring.' + who + ': ' + s + ' is not a state in 0-719');
  return s;
};
const ckAngle = (a, who) => {
  const m = MARK_INDEX.get(a);
  if (m === undefined) throw new RangeError('ring.' + who + ': ' + a + ' is not one of the eleven marks');
  return m;
};
// Nine of the eleven marks have two distinct targets, so a missing or fat-fingered sign silently
// returned the +θ half. Zero is refused too: it is ambiguous for those nine and a uniform rule beats
// one that happens to be harmless at 0 and 180.
// The two halves of the 720-address space are direct and retrograde, and two natives with Mars at 0
// Aries and different motion are not in the same condition — so a truthy string must not be allowed
// to choose between them. Same reasoning as ckSign; omission throws rather than defaulting to direct.
const ckBool = (v, who) => {
  if (v !== true && v !== false) throw new RangeError('ring.' + who + ': retrograde must be true or false, got ' + v);
  return v;
};
const ckSign = (v, who) => {
  if (typeof v !== 'number' || !Number.isFinite(v) || v === 0) throw new RangeError('ring.' + who + ': sign must be a non-zero number, got ' + v);
  return v < 0 ? 0 : 1;
};
const ckFinite = (v, who) => {
  if (typeof v !== 'number' || !Number.isFinite(v)) throw new RangeError('ring.' + who + ': ' + v + ' is not a finite longitude');
  return v;
};

// ---------- the state encoding ----------
// 0-359 direct · 360-719 retrograde · absolute degree = state mod 360 · retrograde state = d + 360.
// Two natives with Mars at 0 Aries, one retrograde, are not in the same condition, and the
// vocabulary has to be able to say so. But motion is a quality of an OCCUPANT and never enters a
// degree-to-degree relation, which is why the relation below is over 360 and not 720.
const deg = (s) => s % DEGREES;                               // internal, post-validation
const degreeOf = (state) => deg(ckState(state, 'degreeOf'));
const isRetro = (state) => ckState(state, 'isRetro') >= DEGREES;
const directState = (d) => Math.floor(norm360(ckFinite(d, 'directState'))) % DEGREES;
const retroState = (d) => directState(d) + DEGREES;
const statesFor = (d) => { const s = directState(d); return [s, s + DEGREES]; };
// An occupant's address. lon is real-valued; the state is its whole degree plus its motion.
const stateOf = (lon, retro) => (Math.floor(norm360(ckFinite(lon, 'stateOf'))) % DEGREES) + (ckBool(retro, 'stateOf') ? DEGREES : 0);

// ---------- the fine address space ----------
// THE DIE DOES NOT GROW. Every mark is a whole number of degrees, so a whole-degree lattice already
// resolves all eleven exactly and 1.296 million rows would buy nothing: TARGETS and MARK_AT stay at
// DEGREES, and `nearest` still takes exact reals and quantizes nothing. What the Ring gains here is
// the UNIT and the address, because PRECISION IS A PROPERTY OF THE OCCUPANT and the relation is the
// die. A resonator can detect drift and re-align a derived state; it cannot recover arcminutes that
// were never encoded, and whole degrees pin a moment only to about four minutes of clock.
//
// THE SHAPE IS THE COARSE SHAPE, SCALED: one integer per occupant, retrograde in the upper half.
// Three alternatives were weighed and rejected, each for a reason already paid for in this codebase:
// a separate motion field breaks the one property every persisted row and all three golden fixtures
// depend on (a genome is a list of integers); a negative value for retrograde restages the
// `targetDegree` returned -1 bug, since 0 direct and 0 retrograde would collide and a negative index
// would reach a typed array; and keeping the gene coarse with a parallel arcsecond array leaves the
// coarse value as the identity, so the identity never actually gets finer and two arrays can disagree
// about one placement. The offset's MAGNITUDE means nothing. It is a flag that happens to be
// addressable as arithmetic, and its one load-bearing property is that reduction is a single modulo.
const ckFine = (s, who) => {
  if (!Number.isInteger(s) || s < 0 || s >= FINE_STATES) throw new RangeError('ring.' + who + ': ' + s + ' is not a fine state in 0-' + (FINE_STATES - 1));
  return s;
};
const asec = (s) => s % ARCSECONDS;                           // internal, post-validation
const arcsecOf = (fine) => asec(ckFine(fine, 'arcsecOf'));
const fineIsRetro = (fine) => ckFine(fine, 'fineIsRetro') >= ARCSECONDS;
const fineStateOf = (lon, retro) =>
  (Math.floor(norm360(ckFinite(lon, 'fineStateOf')) * ARCSEC) % ARCSECONDS) + (ckBool(retro, 'fineStateOf') ? ARCSECONDS : 0);
const fineStatesFor = (lon) => { const f = fineStateOf(ckFinite(lon, 'fineStatesFor'), false); return [f, f + ARCSECONDS]; };
// THE PROJECTION, and it is the reason a finer gene costs no rebuild. A cache key is a DELIBERATE
// projection at the resolution the artifact's contents are sensitive to, never an accident: a
// century-long weave does not move for one arcsecond, so filing it under arcseconds would throw away
// 78 seconds of scanning per chart for nothing. Three declared resolutions, top to bottom: sample
// identity is the instant (spine.at stays on jd|lat|lon forever), chart identity is the genome,
// artifact keys are named cuts of the genome. Coarse-from-fine is exact by construction, so the two
// spaces can never disagree about a placement the way two stored arrays could.
const stateOfFine = (fine) => Math.floor(asec(ckFine(fine, 'stateOfFine')) / ARCSEC) + (fine >= ARCSECONDS ? DEGREES : 0);
// Degrees, minutes and seconds of the whole circle. This is UNIT ARITHMETIC, not a meaning: no sign,
// no house, no element. A reader that wants 21 08 37 of Aries subtracts its own sign offset.
const dmsOf = (fine) => {
  const a = asec(ckFine(fine, 'dmsOf'));
  return { degree: Math.floor(a / ARCSEC), minute: Math.floor(a / 60) % 60, second: a % 60 };
};

// ---------- the stamped plate ----------
// TARGETS[(deg * NM + m) * 2 + dir] — dir 0 = the -angle target, 1 = the +angle target. For marks 0
// and 180 both entries coincide (the atlas lists those as a single target); the layout stays uniform
// so no caller has to branch.
const TARGETS = new Int16Array(DEGREES * NM * 2);
for (let d = 0; d < DEGREES; d++) {
  for (let m = 0; m < NM; m++) {
    const a = MARKS[m], i = (d * NM + m) * 2;
    TARGETS[i] = norm360(d - a);
    TARGETS[i + 1] = norm360(d + a);
  }
}
// MARK_AT[sep] — for a WHOLE-degree directed separation, the index of the mark it exactly is, or -1.
// Total and exact, because every mark is an integer.
const MARK_AT = new Int8Array(DEGREES).fill(-1);
for (let m = 0; m < NM; m++) { MARK_AT[MARKS[m]] = m; MARK_AT[norm360(-MARKS[m])] = m; }

// The plate itself stays PRIVATE. It used to be exported as "read-only views" that were the live
// buffers: PLATE.targets[0] = 999 stuck, PLATE.stride = 99 stuck, and MARKS.push() made row() return
// TWELVE entries whose twelfth was read past the fixed stride into the next degree's data. Object
// .freeze does not protect typed-array CONTENTS, so the only way "byte-identical for every reader by
// construction" can be true is for the buffers not to leave. snapshot() hands out fresh copies.
const PLATE = Object.freeze({
  degrees: DEGREES,
  marks: NM,
  stride: NM * 2,
  size: TARGETS.length,
  snapshot: () => ({ targets: Int16Array.from(TARGETS), markAt: Int8Array.from(MARK_AT) }),
});

// ---------- the reads ----------
//
// !!! API-WIDE CONTRACT: 0 IS A VALID VALUE EVERYWHERE, AND 0 IS FALSY.
// This ring is 0-based in every quantity it returns, so a truthiness test on ANY of these is a bug:
//   degreeOf / directState / stateOf  ->  0 is 0 Aries
//   arcsecOf / stateOfFine / fineStateOf / dmsOf.{degree,minute,second}  ->  0 is 0 Aries 0' 0"
//   separation / arcOf                ->  0 is a conjunction
//   relation / exact                  ->  0 is a conjunction; ABSENCE is null
//   targetDegree                      ->  0 is a real target at 0 Aries
//   supplementOf                      ->  0 is the supplement of 180; ABSENCE is null
//   nearest().residual                ->  0 means EXACT, not absent
// Three rules, no exceptions:
//   1. absence is always null, never 0, never undefined, never a negative sentinel
//   2. a programmer error THROWS via ckState / ckFine / ckAngle / ckFinite / ckSign / ckBool — one validator
//      per ARGUMENT KIND, at EVERY entry point, with no exemption for flags, so it can
//      never be mistaken for either of the above
//   3. test `!== null` / `=== null`, or use related(), never truthiness
//   4. the die and the plate are IMMUTABLE, and structurally so: MARKS is frozen, the typed arrays
//      never leave the module, and every loop runs on the captured NM rather than MARKS.length
// Two bugs this closed, both silent: targetDegree returned -1 for an unknown angle (a valid result
// falsy, an error truthy, and a negative index into the plate yielding undefined), and relation()
// returned undefined for a fractional state, which defeats the `=== null` check the contract itself
// prescribes and made related() and `relation() !== null` disagree.

// The exact target degree, one lookup. sign < 0 takes the -angle target. Always a whole degree in
// 0-359; NEVER a sentinel.
function targetDegree(state, angle, sign) {
  const m = ckAngle(angle, 'targetDegree');
  const dir = ckSign(sign, 'targetDegree');
  return TARGETS[(deg(ckState(state, 'targetDegree')) * NM + m) * 2 + dir];
}
// Both state IDs of a target degree, so a caller never reduces anything. Always a pair.
function targetStates(state, angle, sign) {
  const t = targetDegree(state, angle, sign);
  return [t, t + DEGREES];
}
// The whole row for a state: every mark's two exact targets, each with both state IDs. This is the
// atlas row, in code, and it is never partially filled — an unvalidated state used to yield eleven
// structurally perfect entries whose degrees were all undefined.
function row(state) {
  const d = deg(ckState(state, 'row')), out = [];
  // NM is captured at load and TARGETS was stamped to that stride. Mapping over MARKS instead let a
  // mutated die walk off the end of the row into the adjacent degree.
  for (let m = 0; m < NM; m++) {
    const angle = MARKS[m], i = (d * NM + m) * 2, minus = TARGETS[i], plus = TARGETS[i + 1];
    out.push({
      angle,
      single: angle === 0 || angle === 180,
      minus: { degree: minus, direct: minus, retro: minus + DEGREES },
      plus: { degree: plus, direct: plus, retro: plus + DEGREES },
    });
  }
  return out;
}
// The EXACT relation between two states: the mark angle, or null. Geometry depends on absolute
// degree and never on motion, which is why the atlas's retrograde half is a provable restatement of
// its direct half. 0 for a conjunction, null for no relation, and never test it with truthiness.
function relation(stateA, stateB) {
  const m = MARK_AT[deg(ckState(stateB, 'relation') - ckState(stateA, 'relation') + STATES)];
  return m < 0 ? null : MARKS[m];
}
// The trap-free door, and it agrees with `relation() !== null` on every input either accepts.
function related(stateA, stateB) {
  return MARK_AT[deg(ckState(stateB, 'related') - ckState(stateA, 'related') + STATES)] >= 0;
}

// ---------- separation, and the nearest mark ----------
// Occupants are REAL-VALUED. These take longitudes, not states.
const separation = (lonA, lonB) => norm360(ckFinite(lonB, 'separation') - ckFinite(lonA, 'separation'));
const arcOf = (sep) => { const s = norm360(ckFinite(sep, 'arcOf')); return s <= 180 ? s : 360 - s; };

// NEAREST IS ARITHMETIC OVER THE SAME ELEVEN MARKS, NEVER A SECOND TABLE, and the residual is
// measured to the mark's EXACT angle. Nothing is ever quantized to a state: quantizing would cost up
// to half a degree, which is 5x the ingress residency guard and 25x the contact guard.
//
// It exists because the app disagrees with itself: astrodna.calcAspects does not break on first
// match and the DC's _aspectSnapshot does, so one prefers nearest and the other prefers table order.
// The justification is TOTALITY AND SINGLE-VALUEDNESS, never speed — eleven abs() calls cost nothing.
//
// TIES RESOLVE TO THE LOWER ANGLE. Nine arcs sit equidistant between marks:
//   37.5 · 52.5 · 66 · 81 · 105 · 127.5 · 139.5 · 147 · 165
// MARKS is ascending and the comparison is strict, so the lower angle holds a tie by construction.
// A non-finite separation THROWS rather than returning {angle: 0}, which fabricated a conjunction.
function nearest(sep) {
  const arc = arcOf(sep);
  let angle = MARKS[0], residual = Math.abs(arc - MARKS[0]);
  for (let m = 1; m < NM; m++) {
    const r = Math.abs(arc - MARKS[m]);
    if (r < residual - 1e-12) { residual = r; angle = MARKS[m]; }
  }
  return { arc, angle, residual };
}
// The mark a real separation exactly is, or null. No tolerance: an orb is a reader's cut.
// Same as relation(): 0 for a conjunction, null for absence. A residual of 0 means EXACT, not absent.
function exact(sep) { const n = nearest(sep); return n.residual === 0 ? n.angle : null; }

// THERE IS NO ORB HERE. An orb is not a tolerance; it is a mark widened into an arc, and containment
// rather than comparison. Thresholds belong to the reader (♍ Orb), and taper decisions belong with
// them. Where the sky cancels, the halving is EXACT GEOMETRY and not a policy: two Moons 116 apart
// read 58 or 122 synchronically, 2 off in both, because the same relationship is being read at half
// scale and every length halves with it. Cross-body does not halve — a moving sky term does not
// cancel, so the rate halves and the value does not.
//
// SUPPLEMENT CLOSURE, recorded as a fact of this set and not a defect to repair: 0/180, 30/150,
// 45/135, 60/120 pair and 90 pairs with itself, but 72 and 144 DO NOT (108 and 36 are not marks).
// That is what makes a flip a clean substitution for nine marks and a going-dark for two.
//
// 0 for the supplement of 180, null when the mark has none. THE ARGUMENT MUST BE A MARK: it used to
// accept anything, so supplementOf(108) returned 72 and supplementOf(36) returned 144 — asserting
// precisely the closure the doctrine says does not exist, from the two non-marks the law names.
function supplementOf(angle) {
  ckAngle(angle, 'supplementOf');
  const s = 180 - angle;
  return MARK_INDEX.has(s) ? s : null;
}

window.__ORBO_RING = { MARKS, DEGREES, STATES, TIE, ARCSEC, ARCSECONDS, FINE_STATES, degreeOf, isRetro, directState, retroState, statesFor, stateOf, arcsecOf, fineIsRetro, fineStateOf, fineStatesFor, stateOfFine, dmsOf, PLATE, targetDegree, targetStates, row, relation, related, separation, arcOf, nearest, exact, supplementOf };
})();
