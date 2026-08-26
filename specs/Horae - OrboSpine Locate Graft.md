# Horae - OrboSpine Locate Graft

**Status:** ATTACHED / FINAL GREEN PASS PENDING

## Joint

```text
OrboSpineRuntime.locate
          |
          v
Horae.init(locate:)
```

The finished OrboSpine exposes Door I as `runtime.locate`. Horae is posted at that door by receiving only that Locate surface.

## Law

The graft passes Door I intact. It owns no truth, performs no conversion, and introduces no second Spine representation.

- OrboSpine owns the coordinate system and Locate truth.
- Horae speaks that truth through LIVE and SEEK.
- Horae does not receive or own the whole `OrboSpineRuntime`.
- New Locate behavior, including boundary-anchor truth, passes through Horae without Horae learning how it was made.

## Proof

`HoraeOrboSpineGraftTests.swift` proves:

1. an interior `SEEK(UT)` exactly matches the real runtime Locate cross-section;
2. a boundary-anchor cross-section passes through Horae unchanged.

No Horae production code and no OrboSpine production code are changed by this graft.
