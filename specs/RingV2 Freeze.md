# RingV2 Freeze

Status: FROZEN
Branch: `feature/ring-v2`
Date: 2026-08-23

RingV2 is the canonical native natal aspect authority for OrboCore.

Frozen contract:

- 11 canonical major/minor Ring marks
- 360 universal `RingTemplate`s, one for each `[degree, degree+1)` interval
- 360 cells per template
- exact arcminute/arcsecond propagation through canonical targets
- 360 degree wraparound
- motion-blind geometry with source motion preserved
- AstroDNA object provenance through `RingObjectTemplate`
- direct `AstroDNA -> RingObjectTemplate` handoff via `Ring.objectTemplate(for:in:)`
- no orbs
- no interpretation
- no Lachesis implementation
- no Tapestry construction

Final green gate:

- `swift test --filter RingTemplateTests`: 13 tests, 0 failures
- `swift test`: 317 tests, 0 failures

Any change to this contract reopens RingV2 and requires focused Ring tests plus the full OrboCore suite before refreezing.
