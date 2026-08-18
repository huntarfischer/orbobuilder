# Pass 5: Mundane Timespine Representation Study

**Status:** P22 eleven-body body substrate constructed and persisted. The corrected native Swift/Xcode body-substrate gate passed on 2026-08-17: 98 accumulated OrboCore XCTest passed with 0 failures and OrboLab displayed the live P22 contract. Eclipse and same-body relationship tables remain pending before final serialization and runtime-reader work.

**Date:** 2026-08-17

**Native construction contract:** `AGENTS.md`

**Gate record:** `specs/gates/2026-08-17 Pass 5 P22 Body Substrate Gate.md`

---

# 1. Object

The Mundane Timespine is the universal celestial chronology carried by every Orbo.

```text
same Mundane Timespine version
=
same universal celestial chronology
```

It sits downstream of the Ephemeris and Forge and upstream of ordinary celestial runtime reads.

```text
Ephemeris
    ↓
Forge
    ↓
Mundane Timespine
```

Normal runtime does not reopen the Ephemeris.

---

# 2. 4R

```text
Component: Mundane Timespine
4R: REPRODUCE
Parity: STRUCTURAL
Native owner: OrboCore / MundaneTimespine
```

The prototype and earlier Pass 5 experiments contributed useful artifact/version/proof lessons, but no previous physical Timespine representation is authoritative merely because it was implemented.

The representation is earned by measurement against Orbo's actual celestial-time requirements.

---

# 3. Core temporal law

Orbo runs on celestial time.

For a body, its zodiacal position is that body's celestial time.

```text
Mercury celestial time = Mercury degree
Saturn celestial time  = Saturn degree
Pluto celestial time   = Pluto degree
```

Every occurrence of that repeating celestial time is connected to one civic coordinate measured in UT.

```text
PLANETARY CELESTIAL TIME  ↔  CIVIC TIME
zodiacal position          ↔  UT
```

Civic time distinguishes repeated occurrences of the same celestial coordinate. It is not promoted into the conceptual center of the Timespine.

At one civic instant all body-specific celestial clocks are simultaneous.

```text
UT = T

Sun(T)
Moon(T)
Mercury(T)
...
Pluto(T)
North Node(T)
```

The Timespine therefore stores celestial chronology as repeated body-specific celestial coordinates bound together by shared civic time.

---

# 4. P22 is the first proven Orbo 1.0 Timespine span

The first proven common construction span is the current Pluto Zeitgeist, P22.

```text
P22 Pluto Zeitgeist

Pluto 0 Aries
1822-04-16T13:54:20.135Z
JD 2386637.079399706

        ↓

Pluto 0 Aries
2066-06-17T15:24:10.695Z
JD 2475819.1417904524
```

The supported interval is half-open:

```text
[P22 start, P23 start)
```

The 2066 Pluto 0 Aries boundary belongs to the next Zeitgeist and is not duplicated into P22.

P22 is the first proven common span, not a claim that Pluto is the master celestial clock and not a permanent size limit on Forge or the eventual Mundane Timespine.

Other natural cycles occur inside or cross the Zeitgeist. Saturn Frames, Uranus Revolts, Neptune Waves, and all faster body cycles retain their own celestial-time behavior inside this common civic span.

Forge must remain capable of manufacturing later spans or a larger final chronology without redesigning the organ.

---

# 5. Eleven body tables

The P22 substrate contains eleven focal celestial clocks:

```text
Sun
Moon
Mercury
Venus
Mars
Jupiter
Saturn
Uranus
Neptune
Pluto
True North Node
```

South Node is derived at +180 degrees and is not independently stored.

Each body table is oriented around the focal body's celestial time.

A row is a stored occurrence of a focal celestial-time boundary and carries:

```text
focal celestial time
civic UT coordinate within P22
sequence direction
minimal simultaneous marker celestial times
```

The tables are physically separate because each celestial clock earns its own useful angular density. They remain one Mundane Timespine because one P22 span and one binding contract govern them all.

---

# 6. Earned angular resolution

The P22 study produced a simple two-level body rule.

| Body | Stored celestial-time resolution |
|---|---:|
| Sun | 1 degree |
| Moon | 1 degree |
| Mercury | 1 degree |
| Venus | 1 degree |
| Mars | 1 degree |
| Jupiter | 0.1 degree |
| Saturn | 0.1 degree |
| Uranus | 0.1 degree |
| Neptune | 0.1 degree |
| Pluto | 0.1 degree |
| True North Node | 0.1 degree |

This follows the measured inverse relationship between celestial speed and civic-time spacing.

Fast bodies produce sufficiently close civic anchors at 1 degree. Slow bodies span too much civic time per whole degree, while denser angular storage for them is inexpensive.

One universal angular increment is therefore rejected.

The current P22 body substrate contains 1,811,967 stored body occurrences.

---

# 7. Non-repeating marker law

A focal celestial coordinate repeats. A simultaneous companion celestial coordinate can distinguish which occurrence it is.

Conceptually:

```text
focal celestial time
+
companion celestial time
→
occurrence identity inside P22
```

The P22 audit established Sun celestial time as the common first companion marker for every non-Sun body table.

The selected whole-degree marker sets are:

| Focal body | Companion markers |
|---|---|
| Sun | Pluto + Neptune |
| Moon | Sun + Pluto |
| Mercury | Sun + Pluto + Moon |
| Venus | Sun + Pluto + Mercury |
| Mars | Sun + Pluto |
| Jupiter | Sun + Pluto |
| Saturn | Sun + Jupiter |
| Uranus | Sun |
| Neptune | Sun |
| Pluto | Sun |
| True North Node | Sun + Moon |

Every selected key is non-repeating across the complete P22 Zeitgeist at the focal body's stored resolution.

Mixed-resolution marker experiments can reduce a few marker bit counts, but the current body contract deliberately keeps companion markers at whole-degree resolution. The small theoretical savings do not justify making marker meaning vary table by table during this construction pass.

The marker values also provide cross-body integrity material for the Resonator later. They are not merely database decoration.

---

# 8. Civic coordinate

All eleven tables share one civic coordinate system:

```text
integer seconds from P22 Pluto 0 Aries
```

The complete P22 span requires 33 bits for an integer-second offset.

This shared civic coordinate binds the separate celestial clocks together without making UT the primary meaning of the tables.

---

# 9. Stations and retrograde

A station is a turn in the mapping between a body's celestial time and civic time.

Internally the body chronology records:

```text
increasing celestial time
decreasing celestial time
```

User-facing astrology retains the conventional terms:

```text
direct
retrograde
```

This distinction is especially important for the True North Node, whose normal apparent behavior contains frequent turns and whose decreasing motion is conventionally called retrograde.

P22 persists three shared motion tables:

```text
station-table.csv.gz
retrograde-passages.csv.gz
retrograde-crossings.csv.gz
```

The station chronology is primary structural evidence of each turn. Explicit retrograde/decreasing passages and crossings are retained because they are inexpensive and operationally useful.

---

# 10. Persisted P22 construction artifact

The audit-friendly construction substrate lives at:

```text
tools/pass5/p22-data/
```

with:

```text
summary.json
manifest.json

body-tables/
  Sun.csv.gz
  Moon.csv.gz
  Mercury.csv.gz
  Venus.csv.gz
  Mars.csv.gz
  Jupiter.csv.gz
  Saturn.csv.gz
  Uranus.csv.gz
  Neptune.csv.gz
  Pluto.csv.gz
  NorthNode.csv.gz

station-table.csv.gz
retrograde-passages.csv.gz
retrograde-crossings.csv.gz
```

The manifest records compressed/uncompressed sizes and SHA-256 identity for every compressed table.

The persisted CSV+gzip substrate is construction evidence, not the final shipped binary serialization.

Current measured sizes:

```text
persisted audit-friendly compressed files   37,852,747 bytes
candidate packed body estimate              13,856,254 bytes
```

The final Swift serialization is still to be earned and must preserve the body-layer law above.

---

# 11. Native Pass 5 contract

The native construction surface currently pins only the law already earned from the P22 data:

```text
MundaneBody canonical order
P22 half-open bounds
per-body celestial resolution
per-body companion marker rule
construction record count
shared motion-table identity
33-bit civic-offset requirement
```

It does not yet pretend that the final runtime reader or packed serialization has been earned.

OrboLab reads this live OrboCore contract so a pulled branch visibly reports the same P22 structure being tested.

---

# 12. Superseded Pass 5 representation

An earlier Pass 5 implementation imposed a civic-time sampling model built from:

```text
time-cadenced longitude knots
1700-2150 storage bounds
1950-2050 dense region
three temporal regions
local cubic interpolation
guard knots
second-delta packed knot files
edge/core sample-day profiles
```

That representation is not part of the corrected Pass 5 construction path.

Its knot codec, knot-specific tests, fixture, and qualification workflow are not evidence for the P22 Timespine.

Forge itself remains a permanent native owner. A rejected Timespine manufacturing algorithm does not retire the Forge organ.

Under the current construction contract, superseded material is preserved or quarantined rather than deleted unless the user explicitly authorizes deletion.

Useful general Orbo laws discovered around the earlier work survive only where independently justified, including:

```text
separate body ownership
immutable versioned artifacts
deterministic Forge manufacture
checksums
half-open ranges
accumulated native proof
no routine runtime Ephemeris access
```

---

# 13. AstroDNA codec 4 is a separate contract

Do not call any Timespine representation "codec 4."

In Orbo, **codec 4 refers to AstroDNA codec 4**, the canonical AstroDNA identity contract that uses the true/osculating North Node rather than the mean North Node.

Pass 5 must not alter, rename, or repurpose that identity.

```text
AstroDNA.codec == 4
```

remains intact.

The Mundane Timespine must ultimately satisfy AstroDNA codec 4. It does not share AstroDNA's codec number merely because it feeds AstroDNA.

---

# 14. Proof law

The native Pass 5 proof authority is Swift/XCTest in the normal Xcode worksite.

```text
native/Orbo.xcodeproj
└── OrboCoreTests
```

`MundaneTimespineTests.swift` verifies the native P22 contract against the committed summary, marker audit, manifest, file sizes, and SHA-256 identities while the full OrboCore suite remains green.

`MundaneTimespineForgeTests.swift` verifies the restored native Forge owner and the celestial-time manufacturing law.

A specific guard keeps the unrelated canonical identity explicit:

```text
AstroDNA.codec == 4
North Node gene remains in canonical AstroDNA order
```

Historical construction tooling remains preserved in the repository where useful for archaeology. In particular:

```text
tools/pass5/verify_p22_substrate.py
```

is retained as prior construction evidence only. It is **not** a native implementation dependency, verifier, acceptance gate, or required command. Do not use it to promote Pass 5 status.

No JavaScript, HTML, or Python path may substitute for the native Swift/Xcode proof unless the user explicitly authorizes a separate prototype task.

---

# 15. OrboLab

OrboLab exposes a plain live P22 readout from OrboCore:

```text
Forge native owner and manufacturing law
P22 span
start / exclusive end
11 bodies
total stored body occurrences
33-bit civic coordinate
motion-table families
per-body celestial resolution
per-body marker rule
per-body construction record count
```

OrboLab is diagnostic readout, not proof authority.

On 2026-08-17 the user launched OrboLab in the iPhone 17 Pro simulator and visibly confirmed the live P22 contract, including:

```text
P22 Pluto Zeitgeist
1822-04-16T13:54:20.135Z
2066-06-17T15:24:10.695Z exclusive
11 bodies
1,811,967 body records
33-bit civic offset
station / retrograde tables
True North Node direct/retrograde terminology
body resolution and marker rows
```

Result:

```text
OrboLab build/run/readout    PASS
```

---

# 16. P22 body-substrate gate: passed 2026-08-17

The corrected P22 body-layer gate was run from the normal `native/Orbo.xcodeproj` worksite.

Observed native proof:

```text
OrboCoreTests             98 tests
failures                   0
MundaneTimespineForgeTests 4 / 4 PASS
MundaneTimespineTests      6 / 6 PASS
OrboLab live readout       PASS
```

The complete evidence record is:

```text
specs/gates/2026-08-17 Pass 5 P22 Body Substrate Gate.md
```

This closes only the P22 body substrate and the first concrete native Forge manufacturing law.

It does not seal the complete Mundane Timespine.

---

# 17. Remaining Pass 5 construction order

The next work is not final packing yet.

The universal temporal anatomy still needs its remaining admitted relationship/event tables before the final shipping representation is frozen.

Current order:

```text
1. Eclipse table / eclipse index
2. Same-body relationship tables: define and prove the admitted representation
3. Remaining universal exact celestial relationship indexes
4. Sand generic Forge so P22-specific validation lives in the P22 recipe, not the generic owner
5. Final Swift storage serialization
6. Bidirectional runtime reader
      civic UT -> celestial state
      celestial time -> civic occurrence(s)
7. Resonator
8. Final artifact binding/version identity
9. Shipping-resource installation
10. Final astronomical conformance proof
11. Accumulated Xcode gate + OrboLab gate + documentation update
```

No final representation ruling for the same-body tables is made here. That work remains to be designed before implementation.

The next construction discussion begins with the eclipse table.
