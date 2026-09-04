# Apollo Astrolabe Workshop Act I gate — September 4, 2026

Status: **GREEN**.

Active specification: `specs/ApolloAstrolabe-Workshop-Act-I.md`.

## Construction state

- Working branch was cut directly from `frozen/orbo-mounted-spine-green-2026-09-04` at `7c981d56e922934f0206ba904064319d0d3f9cf3`.
- The checked-out `orbo-v1.orbospine` is the real 216,569,743-byte Git LFS object with SHA-256 `c009ee14231747e6409fb717027a12c74d3236cdd0646f9d8db4f978b0d29191`.
- Apollo now governs the complete Astrolabe rather than only the Aegis token.
- The new production-neutral device types live in OrboCore under Apollo; the SwiftUI surface lives in OrboIris; the workshop app is a separate host target.
- Existing Orbo and OrboLab application sources remain intact.

## Verified evidence

[Run 33929535030](https://github.com/huntarfischer/orbobuilder/actions/runs/33929535030), tested code `a3e4b8ca540babaee67ba8a514631f4fe26ea8b3`, passed on its first attempt.

| Gate | Observed result |
| --- | --- |
| Mounted Spine | 216,569,743 bytes; SHA-256 `c009ee14231747e6409fb717027a12c74d3236cdd0646f9d8db4f978b0d29191` |
| Swift package | 973 tests, zero failures |
| Workshop target | `ApolloAstrolabeWorkshop` built for the installed iPhone simulator |
| Accumulated Xcode | 884 Core + 89 Iris + 1 actual-touch UI = 974 tests, zero failures |
| Installed workshop | Three independent launches emitted `APOLLO_WORKSHOP_READY: real Spine mounted` |
| Captures | Aegis 0 degrees, edge 90 degrees, Tabula 180 degrees |

Artifact `9958507146`, `Apollo-Astrolabe-Workshop-Act-I-Evidence`, is 96,057,514 bytes with SHA-256 `563412efac21899c4905093bd35de8362a3e3b44f8f625eb7a7f4a109d10f710`. It contains the Xcode result bundle, all three 1206 × 2622 simulator captures, and launch logs.

## Visual inspection

- The neutral workshop frame and controls remain stationary across all three captures.
- At 0 degrees, the violet stone Aegis carries actual mounted-Spine body placements, zodiac engraving, subtle grain, rim depth, and a ground shadow.
- At 90 degrees, the faces disappear and the same device resolves to its narrow violet edge; no whole-screen flip occurs.
- At 180 degrees, the Tabula is readable rather than mirrored. Its twelve destinations follow the prototype order from Natal/Aries through Composite/Pisces, with the Aegis return engraved in the center.
- The Tabula and Aegis are intentionally structural in this act. Prototype-density transcription, sockets, active selections, and material variants remain subsequent workshop work.

The visual inspection found one small capitalization defect in the Aegis's Horae engraving. The follow-up closure commit changes `HORAe` to `HORAE`; it does not alter geometry, data, ownership, or interaction law.

## Gate decision

Act I is green. The Apollo Astrolabe now exists as one independently visible and manipulable SwiftUI device connected to the real Timespine through Horae. This establishes the durable workshop base for the exact prototype transcription and future skins.
