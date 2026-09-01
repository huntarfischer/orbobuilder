# ORBO SYNCHRONIC SPINE
## ACT I — TEST PLAN

## Purpose

Define the Act I test suite before implementation.

The goal is not to copy the Natal Spine test suite line-for-line.

The goal is to establish the behavioral fence around the approved Synchronic Spine architecture so implementation can proceed against clear gates.

The suite should remain organized by the three approved Act I implementation passes:

```text
PASS A
Foundation

PASS B
Fill the Pattern

PASS C
Certification
```

The tests should be sharp enough to identify the lawful owner of a failure without turning every constituent into its own architectural stage.

The governing test philosophy is:

> A handful of gate suites with sharp destructive checks inside them.

---

# PASS A — FOUNDATION TESTS

Pass A covers:

```text
Hermes commission
↓
Clotho Pattern
+
Clotho Bone
↓
Lachesis ready
```

---

# COMMISSION TESTS

Tests should prove:

```text
creates exactly one Synchronic Spine commission for the native

commission purpose is Synchronic Spine Schematic

preserves native identity

does not reuse a Natal Spine commission

prevents duplicate commission creation

commission remains unresolved through Act I
```

Negative proof should include:

```text
wrong native cannot silently substitute

duplicate commission cannot silently open

Natal Spine commission cannot satisfy Synchronic Spine work
```

---

# PATTERN TESTS

The Synchronic Spine Pattern must require exactly:

```text
1 Bone
12 Asteria Passes
7 Themis Imprints
3 Oceanus Tides
12 Rhea Qualifiers
```

Tests should prove:

```text
Pattern requires exactly 1 Bone

Pattern requires exactly 12 Asteria Passes

Pattern requires exactly 7 Themis Imprints

Pattern requires exactly 3 Oceanus Tides

Pattern requires exactly 12 Rhea Qualifiers

Pattern identity remains tied to original native

Pattern identity remains tied to original commission
```

Off-by-one proof should include:

```text
11 Asteria Passes ≠ fulfilled
13 Asteria Passes ≠ fulfilled

6 Themis Imprints ≠ fulfilled
8 Themis Imprints ≠ fulfilled

2 Oceanus Tides ≠ fulfilled
4 Oceanus Tides ≠ fulfilled

11 Rhea Qualifiers ≠ fulfilled
13 Rhea Qualifiers ≠ fulfilled
```

---

# BONE TESTS

Tests should prove:

```text
START = natal minus 1 Gregorian year

NATAL = exact natal instant

END = natal plus 100 Gregorian years

START < NATAL < END

Bone preserves native identity

Bone belongs to the Synchronic Spine commission

Bone cannot silently change after Clotho cuts it

downstream matter outside the Bone is rejected
```

---

# PASS A INTEGRATION TEST

Run:

```text
ORBO
↓
HERMES
↓
CLOTHO
↓
PATTERN + BONE
↓
LACHESIS
```

Prove:

```text
same native

same commission

same Pattern

same Bone

no duplicate object appears during relay
```

If these tests and the accumulated suite are green:

```text
PASS A — GREEN
```

---

# PASS B — FILL THE PATTERN TESTS

Pass B covers:

```text
Asteria
↓
Themis
↓
Oceanus
↓
Rhea
```

Each Titan receives focused proof, followed by a completed-field gate.

---

# ASTERIA TESTS

Asteria should be tested one body at a time, followed by the completed set.

---

## PER-BODY ASTERIA TESTS

For each of the twelve Asteria bodies, tests should prove:

```text
correct native body paired with correct mundane counterpart

no cross-body pairing

same Clotho Bone used

Arc / Asteria owns the composite math

output belongs to correct body

output remains inside START / END

deterministic from identical source matter

natal source remains unchanged

mundane source remains unchanged

provenance resolves back to both source inputs
```

---

## TERRA-SPECIFIC ASTERIA TESTS

Tests should prove:

```text
Terra is included among the 12

Terra uses canonical Terra / Horizon matter

native ASC is the native counterpart

result is the Synchronic Ascendant Pass

no separate ASC engine is created

no separate Horizon engine is created
```

---

## COMPLETED ASTERIA FIELD TESTS

Tests should prove:

```text
exactly 12 Asteria Passes

every required body appears once

no duplicate body

no missing body

Terra present exactly once

declared row count = actual row count

all Passes belong to same native

all Passes belong to same Bone

all Passes belong to same commission
```

If green:

```text
ASTERIA GREEN
```

---

# THEMIS TESTS

Themis should be tested by individual Imprint, then as a complete seven-Imprint field.

---

## INDIVIDUAL THEMIS IMPRINT TESTS

For each required frame, tests should prove:

```text
correct rising sign

canonical Tympan Imprint returned

complete house structure preserved

governance preserved

canonical Tympan truth is not mutated
```

---

## COMPLETED THEMIS FIELD TESTS

The required frames are exactly:

```text
-3
-2
-1
 0
+1
+2
+3
```

Tests should prove:

```text
exactly 7 Imprints

all required frames present

no duplicate frame

no missing frame

no eighth frame

declared count = actual count

all Imprints belong to same native

all Imprints belong to same Synchronic Schematic work
```

If green:

```text
THEMIS GREEN
```

---

# OCEANUS TESTS

Oceanus should be tested as three separate Tide families.

---

## INTER-CHART TIDE TESTS

```text
S ↔ S
```

Tests should prove:

```text
both sides are Synchronic

references resolve to Asteria matter

no Natal contamination

no Mundane contamination

canonical Oceanus / Ring relation law is used

all temporal facts remain inside Bone

declared count = actual count
```

---

## MUNDANE TIDE TESTS

```text
M ↔ S
```

Tests should prove:

```text
exactly one Mundane side

exactly one Synchronic side

Synchronic side resolves to Asteria

does not reproduce M ↔ N Natal Spine work

no S ↔ S rows mislabeled here

declared count = actual count
```

---

## NATAL TIDE TESTS

```text
N ↔ S
```

Tests should prove:

```text
exactly one Natal side

exactly one Synchronic side

correct native

Synchronic side resolves to Asteria

no Mundane contamination

declared count = actual count
```

---

## COMPLETED OCEANUS FIELD TESTS

Tests should prove:

```text
exactly 3 Tides

all three Tide identities present

no duplicate Tide

no fourth Tide

Tide labels cannot be swapped

all references resolve to lawful source matter

all temporal facts remain inside Bone

declared count for each Tide = actual count
```

If green:

```text
OCEANUS GREEN
```

---

# RHEA TESTS

Rhea should be tested one body at a time, then as a completed twelve-Qualifier field.

---

## PER-BODY RHEA TESTS

For each of the twelve bodies, tests should prove:

```text
Qualifier references correct Asteria body

Qualifier qualifies actual degree matter from that body

canonical Mater law is used

no wrong-body attachment

no orphan degree reference

no invented degree

no interpretation added

no new Mater doctrine

source provenance survives
```

---

## COMPLETED RHEA FIELD TESTS

Tests should prove:

```text
exactly 12 Qualifiers

each Asteria body represented once

no duplicate body

no missing body

declared row count = actual row count

all references resolve to lawful Asteria matter
```

If green:

```text
RHEA GREEN
```

---

# SECT YELLOW FLAG

Do not write a test yet that asserts how dynamic Synchronic Sect enters Rhea.

That seam remains intentionally unresolved until implementation reaches the living repository contract.

The test suite should prove only what is already frozen:

```text
Rhea qualifies each body's degree field
using canonical Mater ownership.
```

Do not invent an Act I Hecate dependency merely to make the test suite appear complete.

---

# PASS B INTEGRATION TEST

At the end of Pass B, Lachesis must hold exactly:

```text
1 Bone
12 Asteria Passes
7 Themis Imprints
3 Oceanus Tides
12 Rhea Qualifiers
```

Tests should prove:

```text
correct counts

same native

same commission

same Bone

no missing constituent

no duplicate constituent standing in for another

every constituent preserves lawful provenance
```

If these tests and the accumulated suite are green:

```text
PASS B — GREEN
```

---

# PASS C — CERTIFICATION TESTS

Pass C covers:

```text
Lachesis
↓
Atropos
↓
Pattern fulfilled
↓
Certified Synchronic Spine Schematic
↓
Hermes called
```

No new astrology is created in Pass C.

---

# LACHESIS → ATROPOS HANDOFF TESTS

Tests should prove Atropos receives:

```text
the exact Bone Clotho cut

the exact 12 green Asteria Passes

the exact 7 green Themis Imprints

the exact 3 green Oceanus Tides

the exact 12 green Rhea Qualifiers

same native

same commission
```

Also prove:

```text
no recomputation during handoff

no altered copy replaces a green constituent

no missing field
```

---

# ATROPOS HAPPY-PATH TESTS

Atropos should accept only when:

```text
Bone count = 1

Asteria Passes = 12

Themis Imprints = 7

Oceanus Tides = 3

Rhea Qualifiers = 12
```

And:

```text
every declared row count matches actual

every constituent belongs to correct native

Bone is consistent across all temporal matter

all required references resolve

no duplicate constituent satisfies a missing requirement

no extra constituent is treated as valid Pattern fulfillment
```

When everything is lawful:

```text
PATTERN FULFILLED
↓
CERTIFIED SYNCHRONIC SPINE SCHEMATIC
```

---

# ATROPOS DESTRUCTIVE TESTS

Atropos must reject deliberately corrupted work for the correct reason.

Atropos rejects.

Atropos does not repair.

---

## BONE DESTRUCTIVE TESTS

Test:

```text
wrong START

wrong END

wrong Bone identity
```

Expected:

```text
REJECT
```

---

## ASTERIA DESTRUCTIVE TESTS

Test:

```text
remove one Pass

duplicate one body and omit another

corrupt declared count

remove Terra

replace Terra with another body

wrong native
```

Expected:

```text
REJECT
```

---

## THEMIS DESTRUCTIVE TESTS

Test:

```text
remove one Imprint

duplicate one frame

add an eighth frame

corrupt declared count
```

Expected:

```text
REJECT
```

---

## OCEANUS DESTRUCTIVE TESTS

Test:

```text
remove one Tide

duplicate one Tide

swap Tide identity

corrupt declared count
```

Expected:

```text
REJECT
```

---

## RHEA DESTRUCTIVE TESTS

Test:

```text
remove one Qualifier

orphan a degree reference

attach Qualifier to wrong body

corrupt declared count
```

Expected:

```text
REJECT
```

---

# HERMES COMPLETION TESTS

After certification, tests should prove:

```text
Atropos calls Hermes exactly once

Atropos cannot call Hermes before certification

call references the Certified Synchronic Spine Schematic

original commission identity survives

Hermes does not deliver to Hephaestus yet
```

That boundary proves Act I ends where the approved architecture says it ends.

---

# FINAL ACT I INTEGRATION TEST

Run one complete Act I relay:

```text
ORBO
↓
HERMES
↓
CLOTHO
Pattern + Bone
↓
LACHESIS
↓
ASTERIA
12
↓
THEMIS
7
↓
OCEANUS
3
↓
RHEA
12
↓
LACHESIS
↓
ATROPOS
↓
PATTERN FULFILLED
↓
CERTIFIED SYNCHRONIC SPINE SCHEMATIC
↓
HERMES CALLED
```

The final object must still carry:

```text
same native

same original commission

same Bone

12 lawful Asteria Passes

7 lawful Themis Imprints

3 lawful Oceanus Tides

12 lawful Rhea Qualifiers

intact provenance

matching declared counts
```

Then run:

```text
focused Synchronic Act I integration suite
+
entire accumulated OrboCore suite
```

Only if both are green:

```text
SYNCHRONIC SPINE — ACT I GREEN
```

---

# GOVERNING TEST PRINCIPLE

The test suite should not become another architecture.

It should act as the fence around the architecture.

The implementation standard is:

```text
meaningful architectural pass
↓
focused proof
↓
accumulated green
↓
next pass
```

Use smaller diagnostic tests only when they help identify the lawful owner of failure.

The test suite should remain:

```text
precise enough to catch corruption

simple enough to understand

broad enough not to freeze unnecessary code shape
```
