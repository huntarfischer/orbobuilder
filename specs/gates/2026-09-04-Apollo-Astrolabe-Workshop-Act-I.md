# Apollo Astrolabe Workshop Act I gate — September 4, 2026

Status: **implementation complete; macOS/Xcode gate pending**.

Active specification: `specs/ApolloAstrolabe-Workshop-Act-I.md`.

## Construction state

- Working branch was cut directly from `frozen/orbo-mounted-spine-green-2026-09-04` at `7c981d56e922934f0206ba904064319d0d3f9cf3`.
- The checked-out `orbo-v1.orbospine` is the real 216,569,743-byte Git LFS object with SHA-256 `c009ee14231747e6409fb717027a12c74d3236cdd0646f9d8db4f978b0d29191`.
- Apollo now governs the complete Astrolabe rather than only the Aegis token.
- The new production-neutral device types live in OrboCore under Apollo; the SwiftUI surface lives in OrboIris; the workshop app is a separate host target.
- Existing Orbo and OrboLab application sources remain intact.

## Pending evidence

The branch workflow must record package and Xcode results plus the Aegis, edge, and Tabula simulator captures. This gate must not be marked closed until those artifacts have been inspected.
