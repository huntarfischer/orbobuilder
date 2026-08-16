# Pass 5: Mundane Timespine Representation Study

**Status:** Candidate representation selected and implemented. Full Mundane Timespine v1 astronomical artifact is not yet sealed.

**Date:** 2026-08-16

**Purpose:** Record the representation measurement that chooses the first native Mundane Timespine format, distinguish representation proof from astronomical-source proof, and prevent the construction artifact from being mistaken for a forged v1 sky.

---

# 1. The Object Being Manufactured

The Mundane Timespine is not the old prototype mundane event floor and it is not the old natal TimeSpine.

It must answer:

```text
body + supported absolute time
        ↓
Mundane Timespine
        ↓
celestial longitude
signed longitudinal motion
```

for the eleven universal celestial occupants required by AstroDNA construction:

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
true / osculating North Node
```

The Ascendant is not here. Horizon owns it.

The Mundane Timespine must be:

```text
universal
native-independent
versioned
immutable once released
offline-readable
random-access
compact enough to ship
precise enough to manufacture AstroDNA codec 4
capable of yielding signed longitudinal motion
```

---

# 2. Prototype Lessons Preserved

`mundane.js` contributes the universal-artifact law:

```text
native-independent floor
same artifact for every reader
verified once before shipping
compact packed runtime data
universal temporal indexes may ride beside the chronology
runtime reads decode rather than rescan
```

`timespine.js` contributes temporal-manufacturing lessons:

```text
chunkable construction
seam-safe manufacture
deterministic materialization
version identity
sorted temporal behavior
conformance between expensive source reads and materialized reads
```

`fertilize.js` contributes:

```text
resumable construction
caller-owned yield points
explicit artifact ancestry
packing and codec discipline
```

None of the three prototype objects is the native Mundane Timespine representation.

---

# 3. 4R

```text
Component: Mundane Timespine
4R: REPRODUCE
Parity: STRUCTURAL
Native owner: OrboCore / MundaneTimespine
```

The useful laws survive. The JavaScript event-table forms do not.

---

# 4. Representation Candidates Measured

## Candidate A: dense state knots with cubic Hermite reads

A straightforward representation stores longitude and signed speed at a fixed cadence and reconstructs between knots with cubic Hermite interpolation.

A conservative six-hour cadence across all eleven bodies performed well as an interpolation stress shape, but over the 1700-01-01 through 2150-01-01 construction interval it requires roughly:

```text
657,436 intervals per body
11 bodies
2 x 32-bit state values per knot

about 58 million decimal bytes
about 55 MiB before secondary compression and metadata
```

Advantages:

```text
simple
fast
velocity is explicit
excellent local interpolation
```

Disadvantages:

```text
large
stores position and velocity as parallel sampled facts
more bytes than the same smooth chronology appears to require
```

It remains a useful reference design, but it is not the selected candidate.

## Candidate B: fixed-point Chebyshev segments

The selected candidate stores one polynomial description of longitude for each segment.

```text
Chebyshev degree        7
coefficients/segment    8
coefficient storage     signed Int32
coefficient scale       1,000,000 units / degree
coefficient quantum     0.000001 degree = 0.0036 arcsecond
```

Longitude is evaluated from the polynomial.

Signed longitudinal speed is the analytic derivative of that same polynomial:

```text
one chronology
    ↓
position
+
velocity
```

rather than two independently stored celestial truths.

This is a strong architectural fit for Orbo because velocity remains a node fact while the Timespine carries one mathematical trajectory from which both pointwise facts are read.

---

# 5. Candidate Body Profile

The initial conservative segment profile is:

| Body | Degree | Segment days |
|---|---:|---:|
| Sun | 7 | 16 |
| Moon | 7 | 4 |
| Mercury | 7 | 2 |
| Venus | 7 | 16 |
| Mars | 7 | 8 |
| Jupiter | 7 | 2 |
| Saturn | 7 | 8 |
| Uranus | 7 | 4 |
| Neptune | 7 | 4 |
| Pluto | 7 | 8 |
| True North Node | 7 | 4 |

Across the Gregorian interval:

```text
1700-01-01 00:00
through
2150-01-01 00:00 exclusive
```

this profile requires:

```text
410,901 polynomial segments
3,287,208 Int32 coefficients
13,148,832 coefficient bytes
12.54 MiB coefficient payload
```

before the small artifact header and before any optional future secondary compression.

This is roughly one quarter of the raw six-hour Hermite payload.

---

# 6. Why Fixed Body Cadences First

The v1 candidate deliberately avoids adaptive segment boundaries.

Fixed body-specific cadence gives:

```text
O(1) segment address from Julian Day
no per-segment timestamp table
simple deterministic codec
simple corruption checks
simple random access
simple version comparison
small runtime surface
```

A more elaborate adaptive representation is not justified unless the qualified Swiss measurement shows that this candidate misses either fidelity or size goals.

The representation is allowed to become smarter only when measurement pays for the additional machinery.

---

# 7. Construction Measurement Source Versus Astronomical Authority

The current automated representation stress harness used the locally available Swiss Ephemeris API package, version 2.10.03, but the worksite does not contain the qualified Swiss `.se1` files.

The harness therefore explicitly used the Moshier mode rather than pretending Swiss-file mode was active.

That harness is useful for:

```text
trajectory-shape stress
wrap behavior
polynomial-degree comparison
segment-duration comparison
rough storage measurement
finding obviously inadequate representations
```

It is **not** the astronomical authority for Mundane Timespine v1.

The Moshier runs also produced occasional discontinuity-like outer-body outliers under some candidate profiles. That is useful evidence against declaring a fidelity contract from this fallback harness.

Therefore:

> **No residual measured from the fallback stress harness is the final Orbo v1 accuracy claim.**

Pass 4 remains authoritative:

```text
qualified v1 Forge reference
=
official Swiss Ephemeris
with the qualified Swiss ephemeris data
and no silent lower-precision fallback
```

---

# 8. Required Swiss-Mode Qualification Before Artifact Seal

Before the full 1700...2149 Mundane Timespine artifact can be called v1, rerun the representation study against the qualified Swiss source and record at least:

```text
maximum angular residual by body
99.9-percentile angular residual by body
maximum signed-velocity residual by body
RingFineState agreement rate
explicit tests immediately around arcsecond rounding boundaries
0 / 360 wrap cases
true North Node direct intervals
true North Node retrograde intervals
stations
ingresses
range-edge reads
random moments across the entire interval
known natal moments
```

If any body fails the earned fidelity threshold, shorten that body's segment duration or change the representation and manufacture a new candidate.

Do not weaken the accuracy contract to protect the representation.

---

# 9. Native Candidate Codec

The native candidate codec is binary.

It carries:

```text
magic
codec
Timespine version identity
AstroDNA codec compatibility
astronomical source identity
astronomical source version
supported start / end Julian Day
coefficient scale
canonical body count
per-body polynomial degree
per-body segment duration
per-body segment count
fixed-point coefficients
```

Bodies are encoded in one explicit canonical order.

The artifact checksum is SHA-256 over the encoded bytes.

The checksum is not a source of celestial truth. It proves byte identity.

Thus:

```text
same declared Timespine version
+
same checksum
=
same shipped chronology bytes
```

---

# 10. Forge Construction Law

The native Forge candidate is resumable.

For every body and every segment it:

```text
selects deterministic Chebyshev-Gauss sample nodes
asks the injected Forge Ephemeris reference for longitude
unwraps the circular longitude locally
fits degree-7 Chebyshev coefficients
quantizes each coefficient to one microdegree
appends it to the body series
```

Construction may be stepped in bounded segment budgets.

The same plan and same reference must produce byte-identical output whether forged:

```text
one shot
or
many resumed chunks
```

That law is tested natively.

---

# 11. Runtime Law

Runtime never asks how the polynomial was forged.

It performs:

```text
Julian Day
    ↓
body series
    ↓
segment index
    ↓
Chebyshev evaluation
    ├── longitude
    └── analytic derivative -> signed longitudinal speed
```

The supported interval is half-open.

A read outside the artifact range fails explicitly rather than extrapolating or opening the Ephemeris.

---

# 12. What Is Not Yet Claimed

This study and its native implementation do **not** claim:

```text
the full Swiss-forged v1 artifact exists
the final body-by-body fidelity thresholds have been earned
the candidate profile is immutable
Swiss code or data have been vendored into Orbo
Pass 5 has passed its final astronomical parity gate
```

Those claims require the qualified Swiss-mode forge run.

The implementation can become native proven before the sky artifact becomes celestial canonical. Those are deliberately separate gates.

---

# 13. Pass 5 Candidate Boundary

At this stage the architecture is:

```text
qualified Ephemeris reference
        ↓
Forge reference socket
        ↓
resumable deterministic Forge
        ↓
fixed-point Chebyshev artifact codec
        ↓
Mundane Timespine reader
        ↓
longitude + signed motion
```

The next proof is native compilation and the accumulated XCTest suite.

The subsequent celestial proof is the full Swiss-mode manufacture and residual audit.

Only after both are green may Mundane Timespine v1 be sealed as the canonical runtime sky.
