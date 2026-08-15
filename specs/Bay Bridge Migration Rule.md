# Bay Bridge Migration Rule

Status: implementation doctrine.

Purpose: define how Orbo replaces load-bearing architecture without first dismantling the working system.

The model is the replacement of the eastern span of the San Francisco-Oakland Bay Bridge: build the new span alongside the old one while traffic continues to move, prove the replacement, switch traffic deliberately, then dismantle the old structure.

For Orbo, this is not merely an analogy. Code allows the working subsystem to be copied and its replacement to be built beside it from identical inputs.

---

## 0. The law

> **Do not destroy the working path in order to discover its replacement. Copy it, rebuild beside it, compare continuously, switch consumers deliberately, then retire the old path.**

Or more compactly:

```text
COPY
BUILD BESIDE
COMPARE
SWITCH
RETIRE
```

A deep architectural rewrite does not earn the right to replace the existing path until it can carry the existing traffic.

---

## 1. Why this fits Orbo

Orbo now has enough interdependent engines that a locally correct rewrite can create globally convincing defects.

Examples of load-bearing systems include:

```text
Connectome
TimeSpine
SynchronicSpine
Lunar Port
AstroDNA decode surfaces
Ring / ruler ownership
interpretation and doctrine contracts
```

Replacing one of these in place creates two risks:

1. the old behavior disappears before parity can be measured;
2. every downstream failure becomes ambiguous because there is no longer a known-good path for comparison.

A parallel build keeps a live reference span available.

---

## 2. The canonical migration sequence

### Phase A: copy the working span

Preserve the current implementation unchanged as the known-good reference.

The copy must include the contracts necessary to reproduce its behavior:

```text
inputs
outputs
cache keys
persistence shape
browser build if applicable
tests
consumer expectations
```

Do not improve the reference copy.

Its purpose is measurement.

### Phase B: build the replacement beside it

The replacement receives the same canonical inputs but may have a different internal architecture.

Example:

```text
AstroDNA / occupant state
          |
          +--------------------+
          |                    |
          v                    v
CURRENT CONNECTOME       RESTORED CONNECTOME
known-good span          new span
          |                    |
          +----------+---------+
                     |
                  compare
```

The new path should not initially own user-visible traffic.

### Phase C: parity harness

Feed both systems identical fixtures and live samples.

Compare every output the old system claims to own.

Parity may be:

```text
byte-identical
numerically equal within an explicit tolerance
structurally equivalent under a declared normalization
```

The comparison rule must be written before differences are accepted.

A difference is either:

```text
BUG
    replacement failed to reproduce an existing truth

INTENTIONAL CHANGE
    architecture deliberately changes the contract
    and the changed doctrine/spec is recorded
```

Never normalize a discrepancy after the fact merely to make the test green.

### Phase D: new traffic uses the new bridge first

Where possible, new capabilities should be built only against the replacement architecture.

This gives the new span real traffic without disturbing existing consumers.

Example during Connectome Restoration:

```text
existing natal reader -> current Expression
new ElectionalSpine    -> restored Connectome API
```

The old system remains available as a comparison oracle where their domains overlap.

### Phase E: switch one consumer at a time

Do not perform a repo-wide flag day.

For each consumer:

```text
identify current owner
capture current output
route through replacement
run parity / acceptance tests
observe in the living app
remove only that consumer's old route
```

A migration is complete at the consumer level before the next dependent consumer is moved whenever practical.

### Phase F: retire the old span

The old path may be deleted only when:

```text
all intended consumers have moved
parity obligations pass
new-only behavior is tested
persistence migration is settled
browser/source mirrors agree
no fallback silently routes back to the old path
```

Deletion is the final act, never the opening act.

---

## 3. The reference implementation is an oracle, not doctrine

The existing working code answers an important question:

```text
What does Orbo do today?
```

It does not automatically answer:

```text
What should Orbo mean forever?
```

This distinction is essential during restoration work.

The known-good span is used to prove preservation of behavior that is meant to survive. It must not prevent correction of a contract that the architecture explicitly decides was wrong or too narrow.

Therefore every migration should classify outputs into:

```text
PRESERVE
    current behavior is canonical

RELOCATE
    behavior stays identical but ownership changes

EXPAND
    old behavior remains a subset of a broader contract

REPLACE
    old behavior is intentionally superseded

RETIRE
    old behavior was accidental / duplicate / obsolete
```

---

## 4. Parallel naming during a migration

Do not give the replacement the old production name until the traffic switch is complete if doing so would make traces ambiguous.

Temporary names may be explicit:

```text
connectomeLegacy
connectomeNext

expressionLegacy
expressionNext
```

or similarly unmistakable migration-only names.

These names are scaffolding.

They should disappear when the migration finishes so Orbo does not permanently carry `v2`, `new`, or `next` architecture as ontology.

---

## 5. Source and browser mirrors

Several Orbo engines have readable ES-module sources and browser-global mirrors.

A Bay Bridge migration treats them as one span with two physical representations.

A consumer is not migrated if:

```text
source uses new path
browser build still uses old path
```

or the reverse.

Parity obligations must include the runtime actually used by the assembled Orbo.

---

## 6. Persistence and codecs

Persisted artifacts are traffic already parked on the old bridge.

A replacement must explicitly decide whether an old artifact:

```text
remains valid
can be read through an adapter
must miss by version / codec
must be rebuilt lazily
must be reminted
```

Never silently read an old persisted shape as though it were the new one.

Version and cache-key changes should cause an honest miss and rebuild when semantic identity has changed.

---

## 7. The Bay Bridge Rule applied to Connectome Restoration

Connectome Restoration is the first major intended use of this doctrine.

The current `connectome.js` sign-stay Expression is functional and valuable. It is also narrower than the intended meaning of a Connectome as a comprehensive map of the neural connections of an AstroDNA state.

Therefore:

> **Do not rewrite the current Connectome in place. Copy the functional implementation and build the restored multi-resolution Connectome alongside it.**

Initial topology:

```text
                       SAME INPUT STATE
                             |
                 +-----------+-----------+
                 |                       |
                 v                       v
       CURRENT SIGN-STAY          RESTORED CONNECTOME
          EXPRESSION                nervous-system map
                 |                       |
                 +-----------+-----------+
                             |
                         PARITY LAYER
```

The restored Connectome must be able to reproduce every current sign-stay Expression fact that remains canonical:

```text
planet / house rows
dispositor chains
bearers
keepers
cycles
receptions
house routing
agency
light
charged state
indexes
```

before existing consumers are switched.

New multi-resolution capabilities can then be added beside that proven layer:

```text
exact positional expression
motion expression
pointwise dignity expression
Ring relationships
relational expression
temporal references
SynchronicSpine references
later electional temporal pathways
```

The current sign-stay cache survives inside the restored architecture at its proper resolution rather than being inflated into a per-sample object.

---

## 8. Consumer-by-consumer Connectome switch

A likely migration order should be derived from actual callers, not assumed here, but the shape is:

```text
current consumer
      |
      v
legacy Expression

then

current consumer
      |
      v
restored Connectome.signStay(...)
```

Each move proves that the broader nervous system can carry the old traffic.

Only after all canonical consumers have crossed should the legacy top-level path be removed.

---

## 9. The rule for the SynchronicSpine

The same doctrine applies when completing the SynchronicSpine.

Current live Pisces calculations remain functional while the cached spine is built alongside them.

For overlapping answers:

```text
live recomputation
       |
       +-------- compare -------- cached SynchronicSpine
```

The spine is lazy-built on first use by a Pisces function that requires it. It is not built at natal engraving.

Once parity is proven, Pisces consumers can move from repeated recomputation to spine reads one at a time.

---

## 10. The rule for Electional work

The current sampled `electional.js` should remain available while a celestial-range ElectionalSpine is developed.

This is particularly valuable because the two architectures answer the same user question by different computational routes:

```text
CURRENT
sample civil times -> score each sample

REPLACEMENT
solve celestial boundaries -> intersect spans -> convert to civil time
```

Their overlap supplies a powerful comparison set.

Differences can then be examined as:

```text
sampling error
new boundary precision
intentional doctrine change
actual implementation defect
```

Do not remove the sampled path until the range solver can demonstrate why its answers differ.

---

## 11. The no-scar-tissue rule

Parallel construction is temporary scaffolding, not permission to keep two architectures forever.

The final system must return to one canonical owner for each truth.

After traffic moves:

```text
remove old route
remove migration adapter if no longer required
remove temporary feature flag
remove legacy cache
remove duplicate tests that test only the dead path
rename replacement to the canonical production name
```

The Bay Bridge doctrine ends with demolition.

Otherwise Orbo accumulates two bridges and every future engineer has to guess which one carries traffic.

---

## 12. Acceptance principle

A replacement is ready for traffic when it satisfies both conditions:

```text
1. It carries the truths the old path was supposed to carry.
2. It can carry the new architectural load the old path could not.
```

Parity alone proves only imitation.

New capability alone proves only novelty.

The replacement must do both.

---

## 13. Working phrase

When a future Orbo architecture pass feels risky, ask:

> **Can we build the new bridge beside the old one?**

In code, the answer will often be yes.
