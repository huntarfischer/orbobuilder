# ORBO LAWBOOK

## Purpose

This is Orbo's repository-level book of binding construction laws.

These laws survive individual passes, branches, implementations, and component rewrites. A local implementation may refine how a law is satisfied. It may not silently weaken, bypass, or redefine the law.

When a law conflicts with implementation convenience, the implementation changes.

---

## Law 1 — Shared-Input Independence

**Status: RESERVED EXISTING LAW**

This law was named by the user before the repository Law Book itself was committed.

Its canonical title is preserved here. Its full original wording is not recoverable from the current repository, so it must not be reconstructed from inference or silently replaced.

Until its canonical wording is recovered or restated by the user, this numbered place remains reserved.

---

## Law 2 — Provenance Is Not Fidelity

> **Knowing the source of matter does not prove that the matter was faithfully preserved.**

A provenance claim establishes where matter says it came from. It does not establish that the descendant still matches that source.

Where fidelity matters, the descendant must be checked against the authoritative source matter itself.

For the Natal Spine forge seam:

```text
provenance string
    ≠
proof of inherited celestial matter

canonical parent Mundane OrboSpine
    →
independent fidelity comparison
```

---

## Law 3 — A Seal May Claim Only What Has Been Independently Verified

> **A seal may claim only what has been independently verified.**

A maker's own construction record is not sufficient authority for the maker's final seal.

If a seal represents several classes of truth, every claimed class must have passed an independent verifier with lawful access to the authority behind that claim.

For the Natal Spine:

```text
Dioscuri approval
    →
Hephaestus may seal

no Dioscuri approval
    →
no Hephaestus seal
```

---

## Law 4 — The Verifier Must See the Authority Behind Each Claim

> **Schematics verify design. Source matter verifies inheritance. Neither substitutes for the other.**

A verifier must be able to reach the lawful authority for each class of claim it is asked to certify.

Do not use one authority as a proxy for another merely because both appear in the same object or package.

For the Natal Spine Dioscuri seam:

```text
Atropos-certified Natal Spine schematics
    →
verify Themis / Oceanus / Rhea embodiment

canonical parent Mundane OrboSpine
    →
verify inherited celestial substrate

forged Natal Spine candidate
    →
object under judgment
```

The Dioscuri must see all three. The candidate may carry provenance and the certified forge commission, but those claims do not replace independent access to their authorities.

---

## Law 5 — The Cable Carries a Snapshot, Not a Leash

> **An Iris Port carries a typed snapshot outward from its source entity to Iris. It does not transfer ownership, control, or presentation across that boundary.**

The source entity remains the owner of the signal. The Iris Port is one-way outward and preserves the signal as a strongly typed, entity-specific payload.

Iris remains the owner of manifestation. The Iris Port owns no presentation and performs no domain work.

An Iris Port must not create a live control or ownership relationship back to its source through callbacks, bindings, or equivalent mechanisms.

The connector is universal. The payload is not. Each entity sends its own lawful signal through the same Iris Port standard.

```text
source entity
    →
IrisPort<Signal>
    →
Iris
    →
manifestation
```

---

## Change History

### 2026-09-02

- Added Law 5, `The Cable Carries a Snapshot, Not a Leash`, establishing the universal Iris Port boundary.

### 2026-08-31

- Created the repository-level Orbo Law Book that had previously been agreed but not committed.
- Reserved the previously named `Law 1 — Shared-Input Independence` without inventing missing canonical wording.
- Added Law 2, `Provenance Is Not Fidelity`, earned by the Natal Spine Hephaestus → Dioscuri verification pass.
- Added Law 3, `A Seal May Claim Only What Has Been Independently Verified`.
- Added Law 4, `The Verifier Must See the Authority Behind Each Claim`.
