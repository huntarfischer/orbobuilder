# Orbo Native Worksite

This directory is the Phase 0 native construction worksite for Orbo 1.0.

It is intentionally separate from the JavaScript/HTML prototype and from `ios-wrapper/`.

## Current Phase 0 contents

- `Orbo/` — production native iOS shell. It should remain visually boring and computationally empty during Phase 0.
- `OrboLab/` — internal development application allowed to expose construction-only readouts.
- `OrboCore/` — Swift computational package with no SwiftUI dependency.
- `Orbo.xcodeproj/` — Xcode project containing the `Orbo` and `OrboLab` application targets, both linked to the local `OrboCore` package.

## Phase 0 law

No meaningful astrological component is implemented here yet.

The temporary `OrboCoreBuild.linkageSentinel` exists only to prove app-to-Core linkage. It carries no product or astrological semantics and should be removed once the worksite connection is proven by the native environment.

Prototype JavaScript, browser mirrors, Capacitor machinery, and standalone HTML remain reference specimens outside this directory. They are not runtime dependencies of native Orbo.

## First gate

The worksite is proven when:

1. `OrboCore` builds independently.
2. `OrboCoreTests` pass independently.
3. `Orbo` builds and launches as a black native shell.
4. `OrboLab` builds and launches and can display the Core linkage sentinel.
5. Both apps consume `OrboCore` without adding SwiftUI to Core.
6. The prototype and `ios-wrapper/` remain unchanged.

This worksite prepares the bench. It does not begin Phase 1 implementation.
