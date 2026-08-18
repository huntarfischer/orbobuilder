# Orbo Native Construction Contract

This file is a mandatory preflight for any agent touching the native Orbo 1.0 rebuild.

Read this before any native write.

The governing native plan remains `specs/Orbo 1.0 Native Construction Plan.md`. This file makes the user's non-negotiable construction constraints explicit so they do not depend on conversational memory.

## 0. Celestial time comes first

**Orbo works in celestial time first. This is the first priority of native construction.**

Do not begin by organizing a temporal object around civil clocks, timestamps, Julian Day, storage convenience, or the shape of an external ephemeris API when the object has a celestial coordinate.

For a body:

```text
planetary celestial time = that body's zodiacal position
planetary celestial time <-> civic UT occurrence
```

The zodiacal degree is the primary temporal orientation. Civic UT is the shared coordinate that identifies which occurrence of that repeating celestial time happened in civil chronology.

```text
CELESTIAL TIME                 CIVIC BINDING
body / event zodiacal degree <-> UT / Julian Day occurrence
```

UT is not celestial time.

At one civic instant, all body-specific celestial clocks are simultaneous. The shared civic coordinate lets Orbo connect them, but it does not become the conceptual center of the system.

This law applies beyond the eleven body tables. **Any universal celestial event with a meaningful zodiacal degree must be oriented by that celestial coordinate first.**

For eclipse tables specifically:

```text
eclipse degree
    = primary table orientation

civic UT / Julian Day
    = occurrence identity and chronological binding
```

Do not design the eclipse table as a timestamp list with a degree attached afterward. The degree is how the eclipse is situated in celestial time; the civic time tells Orbo which occurrence it is.

When a native storage or indexing design conflicts with this priority, the design must change rather than demoting celestial time to metadata.

## 0a. Repository first

Before searching externally, downloading a dependency, inventing a new calculator, or recreating a solved capability, inspect the current Orbo repository and governing specifications for an existing canonical source, integration, artifact, fixture, or dependency.

The repository is construction memory. Do not rely on conversational recall when the repository can answer the question.

The required order is:

```text
current Orbo repository
    -> governing native specifications
    -> existing canonical native owner / dependency / artifact
    -> external research only when something remains genuinely unresolved
```

Do not replace or bypass an already-qualified Orbo dependency merely because an external copy is easier to find.

For current Pass 5 astronomical manufacture, **use the Swiss Ephemeris already established inside the Orbo repository and its existing Forge/Ephemeris construction path**. Do not fetch a separate Swiss copy, substitute another ephemeris, or build a parallel eclipse astronomy engine when the repository source can perform the work.

When a repository capability exists but its exact location or mating surface is unclear, locate it inside the repository first. External search is not a substitute for repository archaeology.

## 1. Native construction is Swift

Production native Orbo is built in Swift.

For the native rebuild:

- implement OrboCore, Forge, readers, codecs, serializers, tests, and OrboLab work in Swift
- use XCTest for native proof
- use Xcode as the human acceptance worksite
- do not introduce JavaScript, HTML, Python, or another language as a native implementation path, verifier, acceptance gate, or substitute architecture
- the JavaScript/HTML prototype may be inspected as archaeology, reference behavior, fixtures, doctrine, and prior art only
- do not modify the JavaScript/HTML prototype during a native pass unless the user explicitly asks for prototype work
- do not use Python as a native construction or verification dependency

If a native requirement cannot yet be satisfied in Swift, record it as pending rather than silently solving it in another language.

## 2. Xcode is the acceptance environment

A native pass is not proven merely because a file compiles, a standalone script runs, CI passes, or isolated tests pass.

The closure sequence is cumulative:

1. build the native component in Swift under its earned OrboCore owner
2. add or update XCTest proof
3. run the component tests
4. run the entire accumulated `OrboCoreTests` suite in the normal `native/Orbo.xcodeproj` worksite
5. require zero failures
6. build and run OrboLab when the component has a useful live readout
7. inspect the live OrboCore readout
8. build the affected native targets
9. update the Native Port Manifest and the active pass/gate documentation
10. only then promote status or move to the next construction piece

Every later pass must keep every earlier native test green.

## 3. Documentation is part of the pass

A meaningful native pass is not complete until its construction record is updated.

Before moving to the next piece, all applicable records must be updated:

- update `specs/Native Port Manifest.md`
- update or create the explicit dated gate record for the pass
- update the active component/pass specification when the earned law, boundary, proof, or pending work changed
- record the actual Xcode test count and failure count
- record the OrboLab/build result when that gate applies
- record what remains pending
- do not promote a component beyond the proof actually completed

A gate record supplements the Native Port Manifest. It does not replace the Manifest update.

The user must not have to remind the agent to run accumulated tests or continue the documentation trail.

## 4. Preserve before changing

No deletion is permitted during native reconstruction unless the user explicitly authorizes that deletion.

If an implementation is superseded:

- preserve it
- move it to an archive/quarantine area on the other side of the repository if separation is needed
- document why it is superseded
- do not erase it

A bad implementation does not imply that its architectural owner is bad.

Examples:

- wrong Forge algorithm -> recode Forge, do not remove Forge
- wrong Timespine representation -> replace the representation, do not infer that Timespine or Forge ownership disappears

When uncertain, preserve.

## 5. One component, one judgment

Do not collapse a cluster of files into one architectural decision.

For each component or organ:

- identify its owner
- identify the law that survives
- identify the implementation that may change
- apply the 4R process only where 4R actually applies
- do not infer removal of an owner from retirement of one implementation

New native components earned from first-principles construction must not be forced into an old 4R label merely because the ledger expects one.

## 6. Forge is a permanent native owner

Forge is Orbo's maker, not its runtime oracle.

The sanctioned deep path is:

```text
Ephemeris
    ->
Forge
    ->
Mundane Timespine
```

Normal runtime reads the Mundane Timespine, not Forge or Ephemeris.

Child spines descend from the Mundane Timespine and other canonical Orbo state. They do not reopen the Ephemeris.

A Forge implementation may be replaced. Forge ownership is preserved unless the user explicitly rules otherwise.

## 7. No silent architecture changes

Do not introduce a new language, runtime path, owner, codec identity, storage authority, verification system, or architectural vocabulary merely because it is convenient.

If a discovery appears to require a structural change:

1. state the discovery
2. show the affected owner and mating surfaces
3. preserve the existing component
4. get the user's ruling when the change is not already dictated by the governing specifications

## 8. Branch discipline

Do not touch `main` during active construction unless the user explicitly directs it.

Work on the current authorized construction branch.

For the current Pass 5 work, that branch is:

```text
agent/timespine-celestial-time-build
```

## 9. Pass closure checklist

Before saying a pass is complete, answer all of these:

```text
Celestial-time-first law preserved?          YES / NO
Repository inspected before external search? YES / NO
Existing canonical dependency reused?        YES / NO
Swift implementation present?                YES / NO
Correct native owner preserved?               YES / NO
New/changed XCTest present?                    YES / NO
Component tests green?                         YES / NO
Entire accumulated Xcode suite green?          YES / NO
Zero failures?                                 YES / NO
OrboLab live readout checked, if applicable?   YES / NO
Affected native build checked?                 YES / NO
Native Port Manifest updated?                  YES / NO
Dated gate record updated/created?             YES / NO
Active pass specification updated?             YES / NO
Pending work stated explicitly?                YES / NO
Any deletion performed?                        MUST BE NO unless user explicitly authorized it
Any non-Swift native dependency introduced?    MUST BE NO unless user explicitly authorized it
```

If any required answer is NO, the pass remains open.

## 10. Current Pass 5 temporal law

The Mundane Timespine is AstroDNA in motion.

For each body:

```text
planetary celestial time = that body's zodiacal position
planetary celestial time <-> civic UT occurrence
```

UT is the shared civic coordinate that distinguishes repeated occurrences. UT is not celestial time.

P22 is the first proven/common construction span, not the permanent size limit of Forge or the Mundane Timespine.

Forge must remain capable of manufacturing later spans or a larger final chronology without redesigning the organ.
