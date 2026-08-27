# Orbo — FOH / BOH MVP

**Status:** FROZEN / PROVEN  
**Branch:** `feature/orbo-mvp`  
**Base:** `feature/iris-chronos-integration`  
**Canonical onboarding source:** root `Orbo Onboarding Script.txt`

## Governing model

Orbo is one living entity with two simultaneous responsibility surfaces:

```text
                         ORBO
                    one living entity
                           │
                 ┌─────────┴─────────┐
                 │                   │
                FOH                 BOH
          faces the player      runs the house
```

Front of House is Orbo's relationship with the player. Back of House is Orbo acting inside his system. The pantheon is entirely BOH. The player meets Orbo; the gods work unseen.

The canonical root onboarding script remains the behavioral source for the first native Orbo path:

```text
Introduction
→ Birth Chart
→ optional Rectification
→ Big Three
```

The existing native `OrboOnboarding.complete(...)` remains the canonical Engraving package factory. It creates the unfinished Engraving with Orbo as sender and the printed itinerary:

```text
Atlas
Moirai
Hestia
```

The existing `HermesCourier` remains the custody and routing owner. Orbo authors and commissions the package; Hermes accepts custody and follows the printed itinerary.

---

# PRE-FLIGHT

## Work

Create `feature/orbo-mvp` directly from the proven `feature/iris-chronos-integration` head.

Verify:

```text
current integration head is unchanged
working tree understood
OrboCore full suite green
570 / 0 remains baseline
```

Inspect read-only before editing:

```text
Orbo Onboarding Script.txt
native/OrboCore/Sources/OrboCore/Onboarding/OrboOnboarding.swift
native/OrboCore/Sources/OrboCore/OrboSystem/Hermes/*
native/Orbo/OrboApp.swift
relevant Iris expression / presentation surfaces
existing onboarding tests
existing Hermes tests
```

No production changes.

## Exit gate

Report branch, base SHA, baseline test count, files inspected, and that no code changed.

STOP.

---

# STAGE 0 · ORBO EXISTS

## Purpose

Create Orbo as a real Core entity before giving him any behavior.

## Production

Create only the minimum Core home for Orbo, preferably:

```text
native/OrboCore/Sources/OrboCore/OrboSystem/Orbo/
    Orbo.swift
    OrboState.swift
```

The exact split may collapse to one file if smaller.

## Required model

`Orbo` must be an instance, not a static namespace.

It must distinguish his two simultaneous responsibility surfaces:

```text
Orbo
├── frontOfHouse
└── backOfHouse
```

FOH state must be able to distinguish at minimum:

```text
resting
onboarding
introducingAstrosphere
ready
```

BOH state must be able to distinguish at minimum:

```text
idle
engravingCommissioned
engravingInProgress
nativeReady
```

These are state distinctions; names may be sanded without expanding scope.

## Orbo must NOT yet

```text
run dialogue
store birth data
create Engraving
call Hermes
know Atlas
know Moirai
know Hestia
know Hephaestus
calculate astrology
render UI
own Iris
```

## Tests

Create focused Orbo Stage 0 tests proving:

```text
1. A fresh Orbo can be instantiated.
2. FOH begins in its canonical pre-onboarding state.
3. BOH begins idle.
4. FOH and BOH are independently observable state within one Orbo.
5. Changing one lane does not implicitly mutate the other.
```

No UI tests.

## Gate

Run targeted Orbo tests and the full Swift package suite. Commit production and tests in bounded commits. Report exact files, commits, and test totals.

STOP.

---

# STAGE 1 · FOH SCRIPT CONTRACT

## Purpose

Transpose the canonical root onboarding script into a deterministic behavioral contract Orbo can perform.

## Production

Add the smallest script/session types necessary under Orbo. Likely concepts:

```text
OrboOnboardingSession
OrboOnboardingBeat
OrboOnboardingResponse
OrboOnboardingProgress
```

Do not create a generic dialogue engine.

## Canonical script order

### INTRODUCTION

```text
Welcome, traveler.
My name is Orbo. What's yours?
```

Player supplies name.

Then:

```text
Heya, [name]. It's nice to meet you.
I am your guide to the astrosphere,
the cosmic dimension on top of your own.
How interested are you in astrology?
```

Player chooses:

```text
NOT VERY
INTERESTED
VERY INTERESTED
```

This records the player's reading-depth preference:

```text
L1
L2
L3
```

Then:

```text
Everyone has their place in the astrosphere.
Let's find yours.
```

### PART TWO · BIRTH CHART

Orbo asks:

```text
What day were you born?
```

Player supplies birth date.

Orbo asks:

```text
Where were you born?
```

Player supplies birthplace.

Orbo asks:

```text
Do you know what time you were born?
```

Player chooses yes or no.

If YES:

```text
Orbo requests exact birth time.
Known-time branch becomes commissionable.
```

If NO:

```text
session enters rectification-required branch.
```

## Rectification treatment in this MVP

The branch must exist. It must not be silently collapsed into known-time onboarding.

For this MVP:

```text
NO → rectificationRequired
```

The later Part Three script remains represented as the next lawful chapter, but its astrological rectification machinery is not implemented in this pass. The system must not invent a birth time.

## Depth choice

Depth is player/Orbo experience state. It must not be inserted into AstroDNA, Engraving celestial identity, Hermes routing, or Topos.

## Orbo must NOT yet

```text
call Hermes
construct Engraving
calculate Ascendant
calculate Moon
calculate Sun
call Chronos
call Horae
advance to Big Three from guesses
```

## Tests

Prove exact state progression for the known-time route:

```text
start
→ name requested
→ name accepted
→ depth requested
→ depth accepted
→ birthday requested
→ birthday accepted
→ birthplace requested
→ birthplace accepted
→ time-knowledge requested
→ yes
→ birth-time requested
→ birth-time accepted
→ readyForEngraving
```

Also prove:

```text
NO birth time
→ rectificationRequired
→ does not become readyForEngraving
```

Prove invalid-order responses cannot skip the script. Prove depth remains intact throughout.

## Gate

Targeted tests + full suite. Commit. Report. STOP.

---

# STAGE 2 · DUMMY TRAVELER PLAYTHROUGH

## Purpose

Create one deterministic traveler who will remain the same pipeline subject all the way to Hephaestus.

## Test fixture only

Define one canonical known-time dummy native.

Use `Madison, WI` for birthplace because Atlas already has deterministic native coverage for that query and timezone.

Choose deterministic:

```text
subjectID
name
birth date
birth time
birth place
depth choice
```

No random UUIDs in assertions where stable identity is needed.

## Production changes

None unless Stage 1 reveals that Orbo lacks a lawful way to expose completed onboarding information.

If such a surface is required, add only the narrow value necessary, for example:

```text
OrboKnownBirthInput
```

containing only:

```text
subjectID
name
birthDate
birthTime
birthLocation
```

Depth remains separate.

## Test

Run the dummy traveler through the real Orbo script, one answer at a time. Do not call `OrboOnboarding.complete(...)` directly in the test.

Prove at the end:

```text
FOH knows onboarding is complete for known-time path
BOH remains idle
all five Engraving input facts are preserved exactly
depth preference remains separately preserved
nothing astrological has been calculated
```

## Gate

Targeted tests + full suite. Commit only if production changes were required. Report. STOP.

---

# STAGE 3 · BOH COMMISSIONS ENGRAVING

## Purpose

Make Orbo perform his first backstage action.

## Production

When the known-time FOH session reaches `readyForEngraving`, Orbo BOH gains one explicit action:

```text
commissionEngraving(...)
```

That action must use the existing canonical `OrboOnboarding.complete(...)`. Do not duplicate its package construction.

## Required resulting package

```text
HermesPackage<Engraving>

sender:
orbo

subject:
dummy native

contents:
name
birthDate
birthTime
birthLocation
unresolved Topos
unresolved AstroDNA
unresolved Tapestry
engraved false

addresses:
1. orbo.atlas
2. orbo.moirai
3. orbo.hestia
```

## State transition

```text
FOH
remains active

BOH
idle
→ engravingCommissioned
```

FOH must not jump to Big Three.

## Orbo must NOT

```text
resolve Atlas
touch Clotho
create AstroDNA
cast chart
call Titans
mark engraved
send directly to Hestia
```

## Tests

Prove:

```text
1. Commission cannot occur before sufficient onboarding data exists.
2. Known-time completed onboarding can commission exactly one Engraving.
3. Package sender is Orbo.
4. Package subject matches dummy native.
5. All input information survives byte-for-value.
6. Package itinerary is exactly Atlas → Moirai → Hestia.
7. Topos is nil.
8. AstroDNA is nil.
9. Tapestry is nil.
10. engraved == false.
11. Depth preference is not inside the Engraving.
12. FOH remains active after commission.
```

Choose and test an explicit duplicate-commission policy. Do not permit duplicate independent Engravings for one onboarding completion.

## Gate

Targeted + full suite. Commit. Report. STOP.

---

# STAGE 4 · ORBO CALLS REAL HERMES

## Purpose

Complete the first actual BOH handoff.

## Production

Give Orbo BOH access to the real `HermesCourier`. Prefer dependency injection rather than constructing an invisible second Hermes internally if existing architecture permits it.

Orbo performs:

```text
commission Engraving
↓
entrust package to HermesCourier
```

Hermes remains owner of ticket creation, manifest, custody, and delivery progression.

## Required state

After Hermes accepts:

```text
BOH:
engravingInProgress

reference:
Hermes ticket identity sufficient to track Orbo's commission
```

Orbo may retain the ticket identity. Orbo may not retain a duplicate Hermes manifest.

## Tests

With the same dummy traveler:

```text
1. Run real FOH script.
2. Complete known-time onboarding.
3. Commission real Engraving.
4. Entrust real package to real HermesCourier.
5. Assert Hermes returns a real ticket.
6. Assert Hermes manifest contains ticketOpened.
7. Assert manifest references same package.
8. Assert package identity is unchanged.
9. Assert subject identity is unchanged.
10. Assert Orbo BOH is engravingInProgress.
11. Assert Orbo does not mutate the itinerary.
12. Assert Hermes still owns custody/routing truth.
```

## Gate

Targeted Hermes + Orbo tests. Full suite. Commit. Report. STOP.

---

# STAGE 5 · FOH CONTINUES WHILE BOH WORKS

## Purpose

Prove that Orbo remains the player's host while Olympus works backstage.

## Production

Add only the minimum FOH chapter needed to move from birth-data collection into Astrosphere introduction.

This is not the Big Three yet.

Create a deterministic FOH progression after the commission has left:

```text
onboardingDataComplete
→ astrosphereIntroduction
→ layoutIntroduction
```

Exact prose can reuse established Orbo copy where already canonical. Do not create new astrological claims.

## Core law

FOH progression must not depend on manually advancing Hermes.

The state must permit:

```text
FOH = introducingAstrosphere

at the same time as

BOH = engravingInProgress
```

## Iris boundary

Core exposes presentation-neutral Orbo state/beat.

Iris may render Orbo body, current spoken/text beat, available player responses, and current FOH presentation mode.

Iris must not decide which question comes next, whether onboarding is complete, whether Engraving should be commissioned, whether Hermes should be called, or whether natal truth is ready.

## App integration

Only at this stage, if needed, begin replacing the current direct Iris demonstration host with a minimal Orbo-hosted entry path. Do not delete proven Iris demonstration machinery unnecessarily.

## Tests

Core:

```text
1. Hermes has accepted commission.
2. BOH remains engravingInProgress.
3. FOH advances into Astrosphere introduction.
4. FOH can advance more than one beat while BOH remains unchanged.
5. BOH state does not dictate FOH copy.
6. FOH does not expose Hermes/deity names or internal tickets.
```

Presentation, if introduced:

```text
7. Iris renders current Orbo beat.
8. User action returns to Orbo.
9. Iris does not mutate script state directly.
```

## Gate

Targeted + full suite. If app code changes, compile the appropriate app target as well. Commit. Report. STOP.

---

# STAGE 6 · BOH RESULT FIREWALL

## Purpose

Define the one-way seam by which backstage work can make new player-facing truth available without exposing the gods.

## Production

Add a minimal result/event vocabulary owned by Orbo. It describes consequences, not divine workflow.

Candidate outcomes:

```text
nativeTruthReady
natalSpinePreparing
natalSpineReady
```

For the Orbo MVP, only the first is required.

Do not expose:

```text
AtlasResolved
ClothoFinished
ChronosAnswered
HoraeLocated
TitanPassReceived
AtroposApproved
HestiaAccepted
HearthLit
HephaestusStarted
HermesDelivered
```

Those remain BOH facts.

## MVP injection

At this stage, `nativeTruthReady` may be injected by a test harness because the complete pantheon pipeline is not connected yet. The seam must later permit the real Hestia/Hearth completion path to trigger the same Orbo consequence without changing FOH.

## State behavior

Before result:

```text
FOH may introduce Astrosphere
Big Three unavailable
```

After `nativeTruthReady`:

```text
FOH gains eligibility to enter Big Three chapter
```

The result becoming available must not force an immediate UI transition. Orbo decides when FOH reaches the reveal beat.

## Tests

Prove:

```text
1. BOH result can become ready while FOH is mid-introduction.
2. FOH does not jump immediately.
3. Big Three chapter remains unavailable before nativeTruthReady.
4. Big Three chapter becomes available after nativeTruthReady.
5. No deity/internal BOH type crosses into FOH state.
6. No fabricated chart values are created by Orbo.
```

## Gate

Targeted + full suite. Commit. Report. STOP.

---

# STAGE 7 · BIG THREE SCRIPT REENTRY

## Purpose

Reconnect the canonical Part Four script to truth produced elsewhere.

## Production

Implement the FOH Part Four sequence from the root script:

```text
The moment you were born is as unique to you as your DNA.

When you were born, SIGN was on the horizon.

When you were born, the Moon was in SIGN.

When you were born, the Sun was in SIGN.

Your Sun, Moon and rising are known as your Big Three.

The Big Three focus on how you show up in the world.
And how the astrosphere shows up for you.

Would you like a tour?

No thanks.
Yes please.

The astrosphere awaits!
```

The exact positional values must come from established native truth supplied to Orbo. Orbo must not compute them.

## Data dependency

For this MVP stage, use a narrow presentation-ready native result fixture if the actual Moirai pipeline has not yet been connected. Do not hardcode dummy natal results inside Orbo production code.

## Tests

Prove:

```text
1. Part Four cannot begin without nativeTruthReady.
2. Ascendant display reads supplied established truth.
3. Moon display reads supplied established truth.
4. Sun display reads supplied established truth.
5. Orbo does not derive any of the three.
6. Tour choice is FOH-only.
7. Completion places FOH into its post-onboarding ready state.
8. BOH commission identity remains preserved.
```

## Gate

Targeted + full suite. Commit. Report. STOP.

---

# STAGE 8 · ORBO MVP INTEGRATION PROOF

## Purpose

Prove Orbo as one entity running FOH and BOH together.

No new architecture unless a test exposes a real seam defect.

## One end-to-end dummy test

Run exactly one traveler through:

```text
fresh Orbo
↓
FOH greeting
↓
name
↓
depth choice
↓
birthday
↓
birthplace
↓
known birth-time choice
↓
birth time
↓
BOH commissions Engraving
↓
real canonical Engraving package
↓
real Hermes accepts custody
↓
real Hermes ticket opens
↓
BOH engravingInProgress
│
├──────────── concurrently ────────────┐
│                                      │
FOH Astrosphere introduction           BOH remains active
│                                      │
└──────────────────────────────────────┘
↓
test injects nativeTruthReady
↓
FOH reaches Big Three when appropriate
↓
Big Three reads supplied truth
↓
tour choice
↓
FOH ready
```

## Required negative assertions

The integration test must prove the player-facing state contains none of:

```text
HermesTicketID
Atlas
Moirai
Clotho
Chronos
Horae
Lachesis
Titan passes
Atropos
Hestia
Hearth
Hephaestus
```

unless an internal test deliberately inspects BOH.

## Architecture audit

Search production Orbo code for direct ownership violations.

Orbo must not contain:

```text
ephemeris computation
Locate queries
Chronos queries
Horae queries
Ring encoding
AstroDNA construction
Titan petition logic
Tapestry construction
Hestia admission logic
Spine forging
Iris rendering logic
Hermes manifest duplication
```

## Final tests

```text
all Orbo tests
all Hermes tests
all Onboarding tests
full OrboCore suite
app compile if host changed
```

## Freeze

**FROZEN / PROVEN**

Certified implementation commit:

```text
c4035c366197d72f0ad9fb94a19ee301e5ede480
```

Authoritative terminal proof, 2026-08-27:

```text
TympanTests
19 tests / 0 failures / 0 unexpected

OrboCorePackageTests.xctest
603 tests / 0 failures / 0 unexpected

All tests
603 tests / 0 failures / 0 unexpected
```

Freeze statement:

> **Orbo performs the player's onboarding in Front of House, conducts commissioned system work in Back of House, and continues hosting the player while the pantheon works unseen. Orbo presents established truth. He does not manufacture the gods' truth himself.**

STOP.

---

# AFTER ORBO MVP · PIPELINE CONTINUATION

No implementation during the Orbo MVP.

The next work begins with the exact same dummy Engraving and Hermes journey created by the certified Orbo integration test.

```text
PIPELINE 1
Hermes delivers address #1 → Atlas
fix until same package returns with Topos

PIPELINE 2
Hermes delivers address #2 → Moirai

PIPELINE 3
Clotho → Chronos civic resolution

PIPELINE 4
Clotho → Horae birth moment

PIPELINE 5
Terra + Topos → Ascendant
Ring → complete AstroDNA

PIPELINE 6
Clotho → Lachesis

PIPELINE 7
Lachesis casts first chart

PIPELINE 8
Lachesis petitions four Titans

PIPELINE 9
four passes → Lachesis → Tapestry

PIPELINE 10
Atropos quality check

PIPELINE 11
Atropos calls Hermes

PIPELINE 12
Hermes delivers printed address #3 → Hestia

PIPELINE 13
Hestia accepts
Hearth changes BOH world state

PIPELINE 14
Hephaestus now has native fire
Natal Spine available
Synchronic Spine exists with its level qualifier

PIPELINE 15
Hephaestus receives/derives Natal Spine schematic

PIPELINE 16
Hephaestus forges Natal Spine
```

Each pipeline stage uses the same native, the same commission lineage, and the same package ancestry wherever the architecture requires it.

No jumping ahead. No replacement fixtures once upstream matter exists. No next-stage coding without explicit approval.

Every stage ends with:

```text
targeted tests
full suite
bounded commit
report
STOP
```
