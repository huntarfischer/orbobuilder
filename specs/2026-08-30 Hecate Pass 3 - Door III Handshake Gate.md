# Hecate Pass 3 — Door III Handshake Gate

**Date:** 2026-08-30  
**Branch:** `feature/orbo-lawbook-2026-08-30`  
**Law authority:** `ORBO_LAWBOOK.md`  
**Status:** IMPLEMENTED / UPSTREAM GREEN / LOCAL PACKAGE ACCEPTANCE PENDING

## Scope

Pass 3 installs only the smallest living handshake between Hecate and the already-proven Door III resolver.

```text
SpineLinkSet
    ↓
HecateLink
    ↓
OrboSpineLink.resolve
    ↓
OrboSpineResolvedLink
    ↓
Hecate
```

No relational ritual is performed in this pass.

## Production change

`HecateLink` keeps its existing `SpineLinkSet` ownership and gains one method:

```swift
resolve(through doorIII: OrboSpineLink) throws -> OrboSpineResolvedLink
```

The method forwards Hecate's exact Link request to Door III and returns Door III's factual result unchanged.

Hecate does not:

- resolve Timespine addresses herself
- search for substitute points
- reorder members
- receive the wider `OrboSpineRuntime`
- perform RELATE
- perform CAST
- summon a Titan
- consult Kleides
- interpret the result
- persist the resolved matter

## Proof added

`HecateLinkTests` now additionally proves:

1. Hecate hands the exact N-way Link to Door III and receives the exact resolved points in caller order.
2. Hecate surfaces Door III resolution failure rather than substituting another point.

Existing Hecate Link receipt/order tests remain intact.

## Upstream proof

GitHub Actions run `33342952982` completed successfully on the Pass 3 implementation head.

The runner proved:

```text
Door III point resolution                 PASS
Existing Link + Hecate Link regressions   PASS
OrboCore regression suite                 PASS
```

The runner-only suite retains the repository's existing exclusion of `RingTests.swift` for its known CI compiler blocker. This is not a substitute for the full development-Mac package acceptance.

## Local acceptance still required

From `native/OrboCore` on the development Mac:

```text
swift test
```

Pass 3 closes only when the complete local package suite reports zero failures.

## Explicitly not in Pass 3

```text
RELATE grammar
CAST routing
RelationTable
Synastry
Synchronic relation
Composite
Titan SUMMON
Kleides changes
Door II / Chronos changes
Door III address redesign
cross-Spine resolver orchestration
```

Pass 4 may build Hecate outward from this proven handshake only after Pass 3 local acceptance.
