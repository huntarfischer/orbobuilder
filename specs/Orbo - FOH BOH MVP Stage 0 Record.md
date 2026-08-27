# Orbo MVP — Stage 0 Record

**Branch:** `feature/orbo-mvp`  
**Scope:** Orbo exists as one Core entity with independently observable Front of House and Back of House state.  
**Status:** IMPLEMENTED / AWAITING TERMINAL PROOF

## Production

```text
native/OrboCore/Sources/OrboCore/OrboSystem/Orbo/OrboState.swift
native/OrboCore/Sources/OrboCore/OrboSystem/Orbo/Orbo.swift
```

Stage 0 adds only:

```text
Orbo
├── frontOfHouse
└── backOfHouse
```

Front of House state:

```text
resting
onboarding
introducingAstrosphere
ready
```

Back of House state:

```text
idle
engravingCommissioned
engravingInProgress
nativeReady
```

A fresh Orbo begins:

```text
FOH = resting
BOH = idle
```

Internal state transitions are deliberately presentation-neutral and do not couple the two lanes.

## Explicitly not implemented

```text
dialogue
birth data
Engraving creation
Hermes calls
Atlas knowledge
Moirai knowledge
Hestia knowledge
Hephaestus knowledge
astrological computation
Iris rendering
```

## Tests

```text
native/OrboCore/Tests/OrboCoreTests/OrboSystem/Orbo/OrboStage0Tests.swift
```

Proves:

```text
fresh Orbo instantiates
FOH begins resting
BOH begins idle
FOH is independently observable
BOH transition does not mutate FOH
```

## Gate

Await authoritative local terminal proof:

```bash
cd native/OrboCore
swift test
```

Stage 1 must not begin until Stage 0 is green and approved.
