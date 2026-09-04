# Apollo Astrolabe Workshop — Act I

Date: 2026-09-04  
Branch: `feature/apollo-astrolabe-workshop-act-i-2026-09-04`  
Base: `frozen/orbo-mounted-spine-green-2026-09-04` at `7c981d56e922934f0206ba904064319d0d3f9cf3`

## Purpose

Act I establishes the Apollo Astrolabe as one physical, two-faced SwiftUI device in an isolated workshop. The workshop is a staging surface, not a new owner and not OrboLab.

Apollo owns the Aegis, Tabula, shared geometry, material recipe, pose, detents, and interaction meaning. Apollo does not calculate celestial truth. Horae carries one mounted Timespine cross-section into Apollo. Iris receives a one-way immutable signal and displays it.

## Included

- A separate `ApolloAstrolabeWorkshop` app target and shared Xcode scheme.
- The accepted `orbo-v1.orbospine` bundle resource, 216,569,743 bytes, SHA-256 `c009ee14231747e6409fb717027a12c74d3236cdd0646f9d8db4f978b0d29191`.
- An Apollo-owned complete instrument value with Aegis, Tabula, normalized geometry, violet stone material, physical rotation, and 0/90/180/270/360-degree detents.
- A SwiftUI monitor that displays the front, edge, and back while rotating only the object.
- A neutral workshop surface and bottom rotation slider.
- Structural faces: real mounted-Spine placements on Aegis and the complete prototype destination/zodiac ordering on the base Tabula.
- XCTest contracts for destination order, shared geometry, material values, exposure, and detents.
- Simulator captures at Aegis, edge, and Tabula orientations.

## Deliberately deferred

- Full prototype Aegis and Tabula visual transcription.
- Destination selection, sockets, dish content, and individual engine-port activation.
- Additional skins and material families.
- RealityKit or a polygon mesh.
- Integration into the production Orbo shell.
- Removal of preserved pre-workshop Hermes Tabula preparation.

## Device boundary

```text
mounted OrboSpine -> Horae -> ApolloAstrolabe -> IrisPort -> SwiftUI monitor
                                  |
                                  +-- shared body / Aegis / Tabula / pose
```

The workshop may command Apollo to turn the device. It cannot mutate celestial truth. Iris never owns or interprets the device.

## Acceptance gate

1. The exact artifact hash and byte count pass after Git LFS checkout.
2. The complete Swift package suite passes.
3. The separate workshop target builds for an iPhone simulator.
4. The accumulated Orbo Xcode suite passes.
5. The installed workshop emits `APOLLO_WORKSHOP_READY: real Spine mounted`.
6. Captures visibly prove Aegis at 0 degrees, the physical edge at 90 degrees, and Tabula at 180 degrees, with the workshop frame stationary.

Gate evidence belongs in `specs/gates/2026-09-04-Apollo-Astrolabe-Workshop-Act-I.md` after the macOS run finishes.
