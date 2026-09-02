# Port Building Standard

## Purpose

This document defines the repeatable construction process for Orbo ports.

It does not create a new architectural law. It operationalizes the existing repository law that a port carries a typed snapshot outward without transferring ownership, control, domain work, or presentation.

The standard exists so ports are built when a real boundary requires them, not because every entity is expected to expose every kind of connector.

---

## 1. Start With Ownership

Before a port is designed, identify the lawful owner of the truth that will cross the boundary.

The owner must already possess or lawfully produce the matter being exposed.

Do not create a port by inventing replacement state, reconstructing another entity's truth, or moving domain work into an adapter.

```text
Who owns the truth?
    ↓
What existing typed value carries that truth?
```

If those questions cannot be answered from the living architecture, stop. Do not design the port yet.

---

## 2. Choose the Boundary by Purpose

A port exists because a real receiver needs lawful access to owned truth.

### Direct manifestation

Use `IrisPort<T>` when the source entity owns matter that Iris must directly manifest as part of the Orbo experience.

```text
source entity
    →
IrisPort<EntitySignal>
    →
Iris
    →
manifestation
```

Examples proven in the repository include Apollo, Artemis, and Horae.

### Homer point of view

Use `HomerPort<T>` when Homer needs a lawful point of view into an entity's owned matter for inspection or narration.

```text
source entity
    →
HomerPort<EntityPOV>
    →
Homer
```

The existence of a `HomerPort` does not imply that the same entity also needs a direct `IrisPort`.

If Homer can lawfully expose the required point of view, do not create a second direct Iris manifestation merely for inspection.

---

## 3. The Payload Is Entity-Specific

The connector may be universal. The payload is not.

Prefer the existing typed value already owned by the source entity. If an entity-specific snapshot type is genuinely required, that type belongs with the source entity and must contain only truth that entity owns.

Do not introduce a pantheon-wide payload enum or generic bag of loosely typed state in order to make unlike entities look alike.

```text
IrisPort<HoraeOutput>
HomerPort<HermesPOV>
HomerPort<HecatePOV>
HomerPort<OrboPOV>
```

The commonality is the cable, not the reality carried through it.

---

## 4. The Source Authors the Snapshot

The source entity is responsible for authoring the payload placed into the port.

The port performs no domain work.

The receiver may select, arrange, or manifest the received snapshot according to its own lawful responsibility, but it must not recreate or silently replace the source's truth.

```text
owner
    → authors snapshot
port
    → preserves snapshot
receiver
    → uses snapshot within receiver-owned responsibility
```

---

## 5. Port Boundaries Are One-Way

A port must not create a live ownership or control relationship back into its source.

Do not place the following in a port:

- callbacks into the source
- mutable bindings to source-owned state
- closures that grant downstream control
- domain calculations
- validation or repair belonging to another authority
- presentation code
- navigation or orchestration authority

A port carries a snapshot. It is not a remote control.

---

## 6. Do Not Manufacture State for Inspection

Homer POV does not require every entity to become stateful.

If an entity is a stateless authority that produces a lawful result only when called, Homer may see a real result or context that the entity lawfully owns or has been given. Homer must not force the entity to invent a persistent dashboard state merely to satisfy `HomerPort`.

```text
real owned matter
    → lawful POV

no owned matter
    → no POV yet
```

---

## 7. Build the Smallest Living Seam

A port pass should change only what is necessary to establish the new lawful boundary.

Typical pass:

```text
1. inspect the current owner seam read-only
2. identify the existing payload type
3. add or migrate the port
4. adapt the immediate receiver
5. migrate or add the focused ownership proof
6. run focused tests
7. run full regression
8. audit the branch diff
9. stop at green
```

Do not opportunistically redesign neighboring architecture during a port-standardization pass.

If the port reveals a separate architectural problem that is not required to complete the approved boundary, record it and return for approval rather than expanding scope.

---

## 8. Every Port Gets a Focused Ownership Proof

The minimum useful port test proves that the exact source-authored payload survives the connector unchanged.

Conceptually:

```text
source authors payload
        ↓
Port<payload>
        ↓
receiver
        ↓
same exact payload
```

Additional tests belong only where the entity's existing law requires them, such as provenance or ownership constraints.

A test should prove the living boundary, not merely that a wrapper can be initialized.

---

## 9. Green Gate

A port is not complete until:

```text
focused port proof
    ↓
full package regression
    ↓
scope audit
    ↓
GREEN
```

The scope audit must confirm that the pass changed only the approved owner seam, immediate receiver seam, and necessary tests or documentation.

---

## 10. Decision Checklist

Before building any new port, answer all of these:

```text
[ ] Who owns the truth?
[ ] What exact typed value carries it today?
[ ] Does the receiver genuinely need this truth?
[ ] Is the purpose direct Iris manifestation or Homer POV?
[ ] Can an existing port path already satisfy the need?
[ ] Is the source authoring the payload?
[ ] Is the port free of domain work and presentation?
[ ] Is the boundary one-way?
[ ] Does the focused test prove exact preservation of owner-authored truth?
[ ] Has the full regression passed?
[ ] Has the final diff stayed within approved scope?
```

If any ownership or purpose answer is unclear, stop before implementation.
