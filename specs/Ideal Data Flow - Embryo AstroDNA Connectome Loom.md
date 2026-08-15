# Ideal Data Flow · Embryo → AstroDNA → Connectome → Loom

**Status:** target architecture. Build toward this. This document is a comparison standard for the specs archaeology and subsequent restoration work. It does **not** assert that the current implementation already obeys every boundary below.

This document codifies the data-flow model settled in the August 2026 architecture review.

---

## 0 · The governing idea

**Orbo runs on AstroDNA.**

AstroDNA is not merely a natal-chart storage format. It is Orbo's canonical reading of the celestial clock at a particular moment and place.

The solar system is the clock. Its bodies are hands moving at different rates. The Ascendant is the fastest local hand. The Moon is fast. The Sun, Mercury and Venus move on shorter scales. Mars, Jupiter and Saturn narrow the temporal field further. Uranus, Neptune and Pluto are the deep slow tumblers. The North Node contributes another long cycle.

Their positions are not twelve arbitrary independent numbers. Orbital mechanics constrains which combinations can physically coexist. A repeated Venus longitude does not reproduce the same celestial state because the Moon, Mars, Jupiter, Saturn, Pluto and the other hands occupy different places. The complete ordered combination is therefore an extraordinarily specific celestial fingerprint.

The Ascendant localizes that fingerprint to the terrestrial horizon. AstroDNA is, in practical Orbo terms, a **space-time address produced by the mechanics of the solar system itself**.

Within Orbo's declared finite temporal domain and encoded precision, AstroDNA is intended to function as a practically unique celestial clock reading.

---

## 1 · The whole organism

```text
                         UNIVERSAL / SHIPPED

       RING               TYMPAN              MATER / RULERS
    degree law          house law           zodiac law
       │                   │                    │
       └───────────────────┼────────────────────┘
                           │ reference law
                           │
                       EPHEMERIS
                  private clock mechanics
                           │
                           ▼
                        EMBRYO
                universal celestial organism
                 finite temporal proto-spine
                           │
                    fertilize(address)
                           │
                           ▼
                        ASTRODNA
                  celestial clock reading
                           │
                           ▼
                       CONNECTOME
              expression of this AstroDNA
                           │
             ┌─────────────┼──────────────┐
             │             │              │
          motion       governance      relations
             │             │              │
             └─────────────┼──────────────┘
                           │
                      FORGED RING
                native/state resonance lattice
                           │ targets
                           ▼
                         LOOM
                temporal weaving machinery
                           │
            ┌──────────────┼──────────────┐
            ▼              ▼              ▼
         CONTACT       SYNCHRONIC      OTHER SPINES
          SPINE           SPINE
```

The drawing hides two important cross-connections:

```text
Embryo ───────────────► Loom
    supplies AstroDNA through celestial time

Ring / Tympan / Mater ─► Connectome
    supply universal law referenced during expression
```

The **Resonator** crosses the seams and checks that derived structures remain faithful to their authoritative parents.

---

# PART I · WHAT SHIPS WITH ORBO

## 2 · Universal law exists before a native

The following are shipped law. They are not created for a user and do not belong inside a user's Connectome.

### Ring

The Ring owns universal degree geometry.

It answers questions such as:

- what angular relationship exists between two degrees?
- where are the exact conjunction, sextile, square, trine, opposition and other admitted Ring marks?
- what is the exact separation between two positions?

The Ring does not know a native.

### Tympan

The Tympan owns the universal whole-sign frame logic.

It answers the house/sign rotation created by an Ascendant sign and the structural house frame that follows from it.

The Tympan does not know a native until a particular AstroDNA is referenced against it.

### Mater / Rulers

Mater and the rulership tables own universal zodiacal structure: signs, elements, sign rulership and other stamped zodiacal facts.

They do not belong to a particular chart.

### Ephemeris

The ephemeris is Orbo's private astronomical kernel. It knows how the celestial machinery moves.

It is **capability**, not a general application dependency.

The ephemeris may use whatever internal astronomical representation is appropriate. Nothing downstream should depend on that representation.

### Loom

The Loom is shipped machinery. It is not a spine and not a chart.

Its job is to solve temporal crossings once it has:

1. a moving celestial state through time,
2. a target family or target lattice,
3. a finite temporal range.

The Loom does not own the sky. It does not interpret. It does not decide which targets matter doctrinally. It finds when the supplied moving occupant reaches the supplied target.

---

# PART II · THE EMBRYO

## 3 · The Embryo is Orbo's universal temporal organism

The Embryo is the missing center between the ephemeris and the rest of Orbo.

**The Embryo is the only public celestial door.**

Nothing downstream asks the ephemeris directly for a planetary or horizon state.

```text
EPHEMERIS
    │
    ▼
EMBRYO
    │
    ▼
ASTRODNA
```

The target law is stronger than "only a few files may import ephem.js":

> **No astronomical state leaves the Embryo except in AstroDNA form.**

A downstream engine may request a full AstroDNA or an optimized gene read, but semantically both are reads from the canonical AstroDNA that the Embryo would produce for that celestial address.

## 4 · The Embryo has two inseparable faces

### 4.1 Celestial mint

Given a celestial address, the Embryo produces AstroDNA.

```text
Embryo.fertilize(time, place)
            ↓
         AstroDNA
```

Every physical celestial-state request is a **fertilization**.

Examples:

```text
birth time + birth place
        ↓
Embryo.fertilize(...)
        ↓
Natal AstroDNA
```

```text
scrubbed moment + observing place
        ↓
Embryo.fertilize(...)
        ↓
Moment AstroDNA
```

```text
horary question time + place
        ↓
Embryo.fertilize(...)
        ↓
Horary AstroDNA
```

The role changes. The celestial grammar does not.

### 4.2 Universal proto-spine

The Embryo also ships a finite, native-independent temporal backbone.

It is the sky's own temporal structure before a native exists. The current implementation's generated Embryo covers a finite historical/future range; the exact supported range is a versioned property of the artifact, not an infinite promise.

The proto-spine contains native-independent temporal truths worth verifying and indexing once, including the appropriate universal families such as:

- planetary ingresses
- stations
- retrograde periods
- mutual planetary aspect perfections where appropriate
- lunations
- eclipses
- other native-independent structural events admitted by the final Embryo contract

The proto-spine is **not** a gigantic archive of AstroDNA for every second. It is a sparse temporal skeleton plus a celestial mint capable of producing the exact AstroDNA at an arbitrary supported address when needed.

```text
EMBRYO PROTO-SPINE
1700 ─────────────────────────────────────────── 2100

     │ ingress
     │      │ station
     │      │       ╞════ retrograde span ════╡
     │      │                   │ eclipse
─────●──────●───────────────────●───────────────

row.jd
   ↓
Embryo.fertilize(row.jd, place)
   ↓
AstroDNA
```

The dates above illustrate the current artifact's range, not a permanent architectural constant.

## 5 · The Mundane Spine is an expression of the Embryo

Historically, the native-independent temporal floor was conceived as a Mundane Spine. In the restored architecture, **mundane astrology reads the Embryo's universal proto-spine; it does not define the Embryo**.

This explains the current archaeological split in which `mundane.js` describes itself as the Embryo's source of truth while the broader concept is larger than a mundane-astrology feature.

---

# PART III · ASTRODNA

## 6 · AstroDNA is Orbo's canonical celestial language

The primary genome is the ordered set:

```text
Ascendant
Moon
Sun
Mercury
Venus
Mars
Jupiter
Saturn
Uranus
Neptune
Pluto
North Node
```

The ordering matters because AstroDNA is an identity-bearing clock reading, not an unordered collection of placements.

### 6.1 The combination lock

Each individual hand repeats. The complete combination does not meaningfully repeat within Orbo's working temporal domain at its intended precision.

A Jupiter longitude may recur roughly every twelve years and may be crossed once or three times within a retrograde cycle. Those occurrences are not the same AstroDNA because the other eleven hands differ.

The slow hands are especially important discriminators:

```text
Pluto / Neptune / Uranus
        ↓
which broad historical field?

Saturn / Jupiter
        ↓
which years inside it?

Mars / Sun / Venus / Mercury
        ↓
which narrower season / month / days?

Moon
        ↓
which narrow temporal window?

Ascendant
        ↓
which local moment and horizon?
```

This is explanatory, not a required decode order.

### 6.2 Position and direction are genomic; detailed motion is expression

The original AstroDNA codec used two directional bands across the zodiac:

```text
0–359     direct whole-degree states
360–719   retrograde whole-degree states
```

The fine-state codec may widen the precision, but the conceptual law remains two equal directional bands: same zodiacal position family, different direction state.

AstroDNA therefore carries the clock hand's position and direction as part of the encoded state.

Detailed motion belongs to the Connectome's expression of that AstroDNA:

- signed velocity
- normalized velocity / speed ratio
- station proximity
- slowing / accelerating where useful
- applying / separating
- crossing family
- next / previous station
- other motion relationships

Velocity is first-class information, but it is not required to rescue the positional genome's uniqueness. The complete positional combination already distinguishes the different historical passages of a repeated individual longitude.

### 6.3 Physical AstroDNA versus derived AstroDNA

A **physical AstroDNA** is minted by the Embryo and claims that this celestial configuration physically existed at the declared time and place.

A **derived AstroDNA** uses the same canonical state grammar but is produced by a declared transformation of one or more AstroDNAs.

Examples may include:

- composite
- synchronic / refracted
- progressed
- other explicitly derived fields

Derived AstroDNA must carry provenance. It must never pretend to be a physical sky state.

The reason to reuse the grammar is architectural: the Connectome can express one canonical state shape regardless of whether its provenance is physical or derived.

### 6.4 Sect belongs to the state being examined

Sect is a geometric property of a state that has a Sun and a horizon.

```text
Sun above the state's horizon  → diurnal
Sun below the state's horizon  → nocturnal
```

Therefore a derived AstroDNA that includes its own derived Sun and derived horizon can have its own sect.

Do not automatically borrow natal sect merely because the state was derived from a natal chart. A doctrine may explicitly ask for natal sect, but that is a doctrinal choice, not the definition of sect.

If a derived state does not possess a meaningful horizon, sect is unavailable rather than silently borrowed.

### 6.5 Lots are derived from the state, not another celestial species

A Lot calculation consumes the relevant state's celestial facts, including that state's sect where the formula requires it.

Lots are therefore derived expression of AstroDNA, not new ephemeris data and not separate celestial authority.

---

# PART IV · THE CONNECTOME

## 7 · The Connectome is the expression network of AstroDNA

The conceptual Connectome is a comprehensive map of the connections expressed by a celestial state.

> **The Connectome is the cached expression of AstroDNA at every useful resolution.**

It is not one monolithic snapshot and it is not equivalent to the current sign-resolution `Expression`. The current sign-stay Expression is one valid tissue within the broader nervous system.

The restored Connectome may expose several expression families or resolution tiers, for example:

```text
ASTRODNA
   │
   ▼
CONNECTOME
   │
   ├── fine / pointwise expression
   │     exact position projections
   │     direction
   │     dignity/bound/face lookups where structurally appropriate
   │
   ├── sign-stay / regulatory expression
   │     sign
   │     house
   │     rulers
   │     dispositors
   │     chains
   │     cycles
   │     receptions
   │     keepers / agency
   │
   ├── motion expression
   │     velocity
   │     speed ratio
   │     station state
   │     applying / separating
   │     crossing families
   │
   ├── relational expression
   │     aspects
   │     exact separations
   │     lots and other state-derived relations
   │
   └── FORGED RING
         personal/state-specific resonance lattice
```

The exact implementation partition is to be designed after the specs archaeology. The ownership law is settled here.

### 7.1 Every AstroDNA gene has its own Connectome table

The Connectome does not merely compile a chart-wide `planetTable` in which every celestial body is interchangeable as one more row. **Each gene in the AstroDNA unfolds into its own addressable expression table inside the Connectome.**

For the primary twelve-gene AstroDNA, the nervous system therefore has twelve first-class gene tables:

```text
CONNECTOME
│
├── Ascendant
│   └── expression table
├── Moon
│   └── expression table
├── Sun
│   └── expression table
├── Mercury
│   └── expression table
├── Venus
│   └── expression table
├── Mars
│   └── expression table
├── Jupiter
│   └── expression table
├── Saturn
│   └── expression table
├── Uranus
│   └── expression table
├── Neptune
│   └── expression table
├── Pluto
│   └── expression table
└── North Node
    └── expression table
```

These tables share a common **grammar**, but they need not be twelve dumb copies of one schema. Each table expresses what is structurally true of that particular gene. The Ascendant is not a planet, for example, but it is still a full AstroDNA gene and must have its own table because it is the local horizon hand that establishes the chart's frame.

A planetary gene table may expose families such as:

```text
VENUS TABLE

IDENTITY
  AstroDNA value
  exact longitude
  direct / retrograde
  sign
  degree
  house

MOTION
  velocity
  speed ratio
  station state
  previous / next station
  crossing family
  applying / separating

GOVERNANCE
  sign ruler
  dispositor
  dispositor chain
  keeper / agency
  houses ruled
  receptions

CONDITION
  domicile / detriment
  exaltation / fall
  triplicity
  bound
  face
  sect-related condition where applicable

RELATIONS
  references to relation records with other AstroDNA genes
  exact separations
  applying / separating relation state
  reception relationships

FORGED RING
  exact conjunction targets
  exact sextile targets
  exact square targets
  exact trine targets
  exact opposition targets
  other admitted Ring marks

TEMPORAL HOOKS
  references into relevant contact, synchronic, progression or other temporal indexes
```

An Ascendant table shares the grammar where it applies but expresses its own nature:

```text
ASCENDANT TABLE

IDENTITY
  AstroDNA value
  exact longitude
  sign
  degree

LOCAL FRAME
  Tympan reference
  complete whole-sign frame
  chart ruler
  MC / IC / Descendant relationships where present

MOTION
  local rotational rate
  next degree / sign crossing
  return crossings

GOVERNANCE
  ruler
  ruler-table reference

RELATIONS
  relation records to the other AstroDNA genes

FORGED RING
  exact Ring targets to the Ascendant degree
```

The point is not to freeze these example columns before archaeology. The settled ownership rule is that **each AstroDNA gene is a first-class node with its own Connectome table**.

> **AstroDNA is compressed celestial identity. The Connectome is AstroDNA unfolded.**

### 7.2 Cross-gene facts are edges, not duplicated node data

The gene tables do not eliminate the graph. A fact that only exists **between** two genes belongs to a cross-gene relation record and is referenced from the relevant gene tables rather than independently recomputed or copied into both.

Conceptually:

```text
CONNECTOME
│
├── GENE TABLES
│   ├── Ascendant
│   ├── Moon
│   ├── Sun
│   ├── Mercury
│   └── ...
│
├── RELATION TABLES / EDGES
│   ├── Sun ↔ Moon
│   ├── Sun ↔ Mercury
│   ├── Venus ↔ Mars
│   └── ...
│
├── HOUSE / GOVERNANCE NETWORK
├── DISPOSITOR CHAINS
├── RECEPTION NETWORK
├── LOT / STATE-DERIVATION NETWORK
└── TEMPORAL INDEX REFERENCES
```

A Venus table may therefore expose something like `relations.Mars`, but that is a pointer into the canonical Venus–Mars edge, not a second independently owned Venus–Mars calculation.

This gives the Connectome its literal neural character:

> **The AstroDNA genes are nodes. Their relations are edges. The Connectome is the traversable graph of both.**

### 7.3 Motion is expressed per gene

The earlier law that detailed motion belongs to the Connectome becomes concrete here. Every movable AstroDNA gene has a motion expression in its own table. That table can reference neighboring Embryo readings, station roots, crossing families and other temporal structures as needed without altering the AstroDNA identity codec.

Retrograde direction remains encoded in AstroDNA's directional band. The Connectome expands that encoded state into richer motion facts such as velocity, station proximity, applying/separating condition and one-or-three crossing families.

### 7.4 The Forged Ring is both per-gene and circle-indexed

The Forged Ring is one Connectome tissue with two traversal directions.

**Gene-facing index:**

```text
Connectome.Venus.forgedRing.trine
Connectome.Mars.forgedRing.square
Connectome.Ascendant.forgedRing.opposition
```

asks:

> What exact celestial degrees resonate with this AstroDNA gene?

**Circle-facing index:**

```text
Connectome.ForgedRing.byDegree[targetDegree]
```

asks:

> What structures in this AstroDNA does this celestial degree strike?

These are two indexes over the same exact lattice, not two copies of the geometry.

This bidirectional indexing is what allows the Loom to receive already-forged target coordinates rather than repeatedly reconstructing natal geometry inside temporal scanners.

## 8 · Ring and Tympan stay outside; the Forged Ring lives inside

The universal Ring and Tympan ship with Orbo and precede every native.

The **Forged Ring** only exists after a particular AstroDNA is referenced against the universal Ring. It therefore belongs **inside the Connectome** as one of that state/chart's derived tissues.

```text
UNIVERSAL RING
      +
   ASTRODNA
      ↓
CONNECTOME.FORGED RING
```

For a natal Venus at an exact longitude, the Forged Ring may permanently contain the exact coordinates at which admitted Ring marks can strike that Venus.

It should support both body-facing and circle-facing questions:

```text
What exact degrees trine natal Venus?
```

and:

```text
What natal structures resonate at this celestial degree?
```

The Forged Ring contains exact geometry. It does **not** bake doctrinal orb policy into the permanent lattice.

> **The Ring owns geometry. Doctrine owns what it admits around that geometry.**

The Forged Ring is a lattice of exact native/state-specific possibilities, not an interpretation.

---

# PART V · THE LOOM

## 9 · The Loom is the temporal weaving machine

The Loom is not a spine. It is the machinery that produces temporal roots and windows from moving AstroDNA and meaningful targets.

The clean distinction is:

> **The Connectome knows the target. The Loom finds the crossing.**

For example:

```text
CONNECTOME / FORGED RING
Natal Venus exact trine targets:
    target A
    target B
            │
            ▼
          LOOM
            │
    Embryo supplies AstroDNA
       through the range
            │
            ▼
When does Jupiter cross A or B?
            │
            ▼
exact roots / windows
```

The current Loom already embodies an important part of this law: it is one scanner parameterized by target sets and does not import the ephemeris in the app path. The target architecture goes one step further: its injected celestial provider should be semantically an Embryo/AstroDNA provider, not an unrelated naked position map.

An optimized single-gene read is acceptable as an implementation optimization if it is definitionally the same gene the Embryo would return in the full AstroDNA for that address.

## 10 · Forward and inverse celestial navigation are one system

Orbo must be able to move in both directions.

### Forward

```text
time + place
    ↓
Embryo
    ↓
AstroDNA
```

### Inverse

```text
celestial condition
    ↓
Loom / target solver
    ↓
candidate times
    ↓
Embryo fertilizes each candidate
    ↓
AstroDNA candidates
```

Example:

```text
Jupiter = 4°17'
      ↓
find every supported crossing
      ↓
JD A · JD B · JD C ...
      ↓
AstroDNA A · AstroDNA B · AstroDNA C ...
```

For a normal retrograde loop, an ordinary longitude crossing family is structurally one or three crossings, with station-degree edge cases and artifact-boundary clipping handled explicitly.

This is the conceptual basis of planet scrubbing. Grabbing Jupiter does not arbitrarily rotate one visual glyph while the rest of the sky stays frozen. It moves the whole celestial clock to a physically legitimate Jupiter occurrence, and every other AstroDNA gene assumes the value orbital reality requires at that instant.

> **Solve in celestial coordinates first. Convert to civil time second.**

---

# PART VI · THE SPINES

## 11 · The Embryo is the common backbone; specialized spines are indexed expressions on it

Every specialized spine must live on the same temporal coordinate system and within a declared supported temporal domain so that different temporal structures can be overlaid without inventing incompatible clocks.

```text
EMBRYO / PROTO-SPINE
════════════════════════════════════════════════

MUNDANE
────●────────────●───────●──────────────────────

CONTACT
───────●────●──────────────────●────────────────

SYNCHRONIC
──────────●────────●────●───────────────────────

PROGRESSION
───────────────╞══════════════╡─────────────────

ZR
────────╞══════════╡──╞══════╡─────────────────

ELECTIONAL
────────────────────╞══╡──╞════╡──────────────
```

A spine is a **domain-specific temporal index of truths already available through AstroDNA, the Connectome, universal law, or an explicitly declared derivation**.

Not every Tabula needs its own spine.

### 11.1 Mundane Spine

A reader-facing expression of the Embryo's own native-independent proto-spine.

### 11.2 Contact Spine

```text
Embryo through time
       +
Natal AstroDNA
       +
Natal Connectome / Forged Ring targets
       ↓
      Loom
       ↓
Contact Spine
```

The sky and native remain two fields; the event is the touch.

### 11.3 Synchronic Spine

```text
Natal AstroDNA
       +
Moment AstroDNA from Embryo
       ↓
refract / derive
       ↓
Synchronic AstroDNA
       +
Prism/static reachability where appropriate
       +
Connectome / Ring targets
       ↓
      Loom
       ↓
Synchronic Spine
```

The SynchronicSpine chronology is lazy-minted on first relevant use, following the later Phase 7 ruling. Static natal refraction constraints may be prepared earlier, but engraving a natal chart does not require materializing the full synchronic chronology.

### 11.4 Progression structures

Progressions are derived celestial states governed by their progression doctrine. Where a progression requires a physical sky reading at a mapped ephemeris date, that physical state is obtained through the Embryo as AstroDNA, never by a progression reader opening the ephemeris itself.

### 11.5 Zodiacal Releasing

ZR does not need the ephemeris to calculate its periods. It nevertheless lives on the same JD/civil temporal coordinate when indexed alongside the other spines so it can overlay the common backbone.

### 11.6 Electional Spine

Electional judgment consumes celestial and derived AstroDNA, Connectome expression, universal structural law and doctrine-selected conditions. It must not manufacture its own sky.

Its eventual search should operate in celestial ranges and structural windows first, then convert surviving solutions to civil clock time.

---

# PART VII · FERTILIZATION AND PERSISTENCE

## 12 · Every physical state call is a fertilization; persistence is a separate question

A fertilization produces AstroDNA.

Persistence depends on why the moment matters.

```text
AstroDNA
│
├── natal
│     engrave permanently
│
├── saved event
│     persist when the user saves it
│
├── horary
│     persist if saved as a chart
│
├── current / scrubbed moment
│     transient
│
└── solver candidate
      usually transient
```

> **Why a moment matters is metadata. What the celestial clock reads is AstroDNA.**

The same principle applies to derived AstroDNA: provenance and role are metadata around the canonical state representation.

## 13 · Engraving is a privileged fertilization

Natal engraving is not a different method of producing celestial data. It is the privileged act in which one Embryo fertilization becomes the native's immutable identity.

At engraving:

```text
birth address
    ↓
Embryo.fertilize(...)
    ↓
Natal AstroDNA
    ↓
ENGRAVE
    │
    ├── persist canonical genome
    ├── preserve relevant motion expression
    ├── express natal Connectome
    ├── instantiate one Connectome gene table per AstroDNA gene
    ├── build canonical cross-gene edge records
    ├── forge the bidirectional Forged Ring lattice
    ├── prepare other true natal invariants
    └── establish cache identities for lazy temporal structures
```

Fertilization does **not** mean every possible specialized spine must be materialized immediately.

The engraving establishes the native-specific substrate from which those structures can later be grown.

---

# PART VIII · THE RESONATOR

## 14 · The Resonator regulates fidelity; it is not another data source

The Resonator is Orbo's permanent regulation mechanism, analogous to regulating a fine watch.

It verifies that derived or cached representations remain faithful to their authoritative parent.

Candidate resonant pairs include:

```text
Ephemeris        ↔ shipped Embryo
Embryo           ↔ AstroDNA
AstroDNA         ↔ Connectome expressions
AstroDNA gene    ↔ corresponding Connectome gene table
Relation geometry ↔ canonical Connectome edge
Universal Ring   ↔ Forged Ring lattice
live derivation  ↔ cached/materialized spine
source module    ↔ browser/standalone mirror
```

The Resonator does not create a second Connectome or a second sky. It performs independent invariant checks, sampled or event-triggered where appropriate.

Examples:

- a shipped Embryo row agrees with a live celestial reconstruction
- an AstroDNA gene projects to the sign the Connectome claims
- a retrograde gene agrees with the motion expression
- each gene table identifies the AstroDNA gene from which it was expressed
- a cross-gene relation edge agrees from both endpoint traversals
- a Forged Ring trine target is exactly 120 degrees from its source gene
- a cached synchronic row agrees with a live refraction at a sampled hinge
- a generated browser mirror agrees with its source contract

The existing test philosophy already contains proto-Resonator behavior. The restoration should gather those checks into a coherent regulating system rather than inventing a second source of truth.

---

# PART IX · AUTHORITY AND ACCESS

## 15 · Authority table

| Object | Ships with Orbo | State/native-specific | Persistent by default | May directly use ephemeris | Primary job |
|---|---:|---:|---:|---:|---|
| Ephemeris | yes | no | code | yes | private astronomical mechanics |
| Ring | yes | no | code/data | no | universal degree geometry |
| Tympan | yes | no | code/data | no | universal whole-sign frames |
| Mater / Rulers | yes | no | code/data | no | universal zodiacal law |
| Embryo | yes | no until fertilized | shipped artifact/code | **yes, privately** | universal proto-spine + AstroDNA mint |
| AstroDNA | produced | yes to a state | role-dependent | **no** | canonical celestial clock reading |
| Connectome | produced/cache | yes to a state | cache/persist by tier | no | expression network of AstroDNA |
| Connectome gene table | produced inside Connectome | yes to one AstroDNA gene | cache/persist by tier | no | first-class local expression of one gene |
| Connectome relation edge | produced inside Connectome | yes to gene pair/network | cache/persist by tier | no | canonical cross-gene relationship |
| Forged Ring | produced inside Connectome | yes | likely persist with native/state cache | no | exact state-specific resonance lattice |
| Loom | yes | no | code | no | solve crossings/windows from targets + AstroDNA through time |
| Specialized spine | produced | often | eager/lazy by domain | no | temporal index |
| Interpretation pack | ships/downloads | no | content | no | meaning / voice |
| Lunar Port | yes | no | UI machinery | no | one-way presentation boundary |

## 16 · The hard boundary

The architectural boundary to enforce is:

```text
ASTRONOMY
Ephemeris
    ↓
Embryo
    ↓
AstroDNA
────────────────────────────────
ORBO'S INTERNAL CELESTIAL LANGUAGE
Connectome
Loom
Spines
Readers
Interpretation
```

Once an astronomical state has crossed the Embryo boundary and become AstroDNA, downstream code must not reopen the ephemeris to rediscover facts already available through that state.

---

# PART X · WHAT THIS MEANS FOR THE CURRENT RESTORATION

## 17 · This is the comparison standard, not a rewrite instruction

During specs archaeology, each living or planned engine should be compared against this target by asking:

1. What celestial or structural input should this engine logically receive?
2. Is that information already available as AstroDNA or Connectome expression?
3. Does the engine manufacture a second sky when it should consume one?
4. Is a repeated derivation actually a universal shipped law, a Connectome expression, a Forged Ring invariant, or a temporal Loom problem?
5. Does its cache key match the resolution at which its truth changes?
6. Is it producing a state, a relation, an event, a span, an assessment, or presentation?
7. Is a materialized table authoritative, or merely an index of truths derivable from a more authoritative parent?
8. Can the Resonator independently verify the seam?
9. Does every AstroDNA gene have a single canonical Connectome table rather than being reconstructed piecemeal by downstream consumers?
10. Are cross-gene facts owned once as edges and traversed from both endpoints rather than duplicated?

## 18 · Known current archaeological divergences to investigate, not patch yet

The living code already contains pieces of this architecture, but they are distributed across historical layers.

Examples already observed:

- the current Embryo concept is split across `mundane.js`, the generator, the packed browser artifact and its tests
- the current AstroDNA implementation performs some astronomical acquisition itself rather than receiving a completed physical state from a singular Embryo door
- current Loom correctly avoids a direct ephemeris import, but its injected probes expose naked positions rather than a formal AstroDNA/gene contract
- current `fertilize.js` describes fertilizing the Embryo but actually builds personal weaves through Loom from injected probes rather than literally consuming the packed Embryo artifact
- the current Connectome implementation is a valid sign-resolution expression tissue, not yet the comprehensive expression network intended by the word Connectome
- the current `planetTable`-style structure must be compared against the target in which each AstroDNA gene has its own first-class expression table and pairwise facts have canonical edge ownership
- some older engines contain indirect or direct alternate sky paths and local copies of facts now owned elsewhere

These are archaeology findings. The Bay Bridge migration rule still applies. Existing traffic remains on the existing span until replacement pathways prove parity.

---

# PART XI · BUILD-TOWARD LAWS

## 19 · Laws to carry forward

1. **Orbo runs on AstroDNA.**
2. **The Embryo is Orbo's universal celestial organism and finite proto-spine.**
3. **The Embryo is the only door through which a physical astronomical state enters Orbo.**
4. **Every physical celestial-state request is a fertilization and produces AstroDNA.**
5. **No astronomical state leaves the Embryo except as AstroDNA or a definitionally equivalent optimized gene read.**
6. **AstroDNA is the celestial clock code: ordered position plus direction, practically unique to moment and place across Orbo's working domain.**
7. **Detailed motion is Connectome expression, not a competing celestial identity system.**
8. **Ring, Tympan and Mater/Rulers are universal shipped law outside the Connectome.**
9. **The Connectome is the cached expression of AstroDNA at every useful resolution.**
10. **Every AstroDNA gene has its own first-class Connectome expression table.**
11. **Cross-gene relationships are canonical Connectome edges, referenced from gene tables rather than independently duplicated.**
12. **The Forged Ring is inside the Connectome because it is derived from a particular AstroDNA referenced against the universal Ring.**
13. **The Forged Ring is bidirectionally indexed: from each gene to its exact target degrees and from each degree back to the structures it strikes.**
14. **The Ring owns geometry. Doctrine owns what it admits around that geometry.**
15. **The Connectome knows the target. The Loom finds the crossing.**
16. **The Loom consumes AstroDNA through time; it does not manufacture its own sky.**
17. **Specialized spines are temporal indexes seated on the Embryo's common backbone.**
18. **A spine may be eager or lazy according to cardinality and use; caching never becomes a second source of truth.**
19. **Derived AstroDNA uses the same celestial grammar with explicit provenance.**
20. **Sect belongs to the state being examined when that state possesses a meaningful Sun and horizon.**
21. **Lots derive from the relevant state's facts and sect rather than borrowing another state's state by accident.**
22. **Orbo supports both directions: celestial address → AstroDNA and celestial condition → candidate addresses → AstroDNA.**
23. **Solve in celestial coordinates first. Convert to civil time second.**
24. **The Resonator verifies seams; it does not create duplicate authorities.**
25. **No architectural rewrite replaces a working path until it can carry the existing traffic.**

---

## 20 · The shortest possible statement

```text
THE EPHEMERIS MOVES THE CLOCK.
THE EMBRYO OWNS THE CLOCK.
ASTRODNA IS A READING OF THE CLOCK.
THE CONNECTOME UNFOLDS THE READING, ONE GENE TABLE AT A TIME.
THE EDGES RECORD HOW THOSE GENES CONNECT.
THE FORGED RING IS THEIR STATE-SPECIFIC GEOMETRIC LATTICE.
THE LOOM FINDS WHEN MOVEMENT STRIKES THE LATTICE.
THE SPINES INDEX THOSE STRIKES THROUGH TIME.
THE RESONATOR KEEPS THE MOVEMENT TRUE.
THE MOON REFLECTS WHAT IT MEANS.
```

That is the data flow Orbo should build toward.
