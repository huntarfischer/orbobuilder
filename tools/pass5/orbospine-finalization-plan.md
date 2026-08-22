# OrboSpine Finalization Plan

Status: approved working plan for closing OrboSpine 1.0 on `agent/mundane-timespine-3d-build`.

## Spine access law

Every Spine exposes the same three access ports:

```text
I    LOCATE
II   LIBRARY
III  LINK
```

### I. Locate

Direct coordinate access.

For OrboSpine the primitive celestial coordinate is:

```text
(body, directionalDegree, UT)
```

Any part may be bound or left open. Example:

```text
(Mercury, 379, *)
```

returns the temporal occurrences of Mercury at that directional degree.

Ingresses remain natural Locate queries. For example, a sign ingress is simply a body reaching directional degree 0, 30, 60, 90, etc. Do not precompute a separate ingress table unless later evidence shows that doing so is worthwhile.

### II. Library

Queryable prepared temporal structures: ways of looking at time as organized chronology or interval rather than as one raw coordinate.

For OrboSpine this includes the structures already forged into the Spine, such as:

- retrograde passages
- station chronologies
- Ring aspect chronologies
- eclipses
- Frame
- Revolt
- Wave
- Zeitgeist

Library is an access law, not a Chronos implementation. Pass 5 leaves Chronos's future query language and behavior outside the Spine.

The Stack Smeld seam may later extend Library with newly worthwhile prepared temporal structures without reforging the sealed Spine core.

### III. Link

Relational access among two or more addressable things.

```text
A x B
A x B x C
...
```

Pass 5 establishes only the common addressability needed for later relation. It does not implement synastry, dating, electional logic, Chronos joins, or the cosmic algorithm.

## Spine Smeld seams

The sealed Spine core has two controlled extension seams:

```text
Celestial Seam -> 0 or 1 Spine Smeld
Stack Seam     -> 0 or 1 Spine Smeld
```

Both mount the same class of auxiliary artifact: a Spine Smeld.

A Spine Smeld must be:

```text
Hephaestus forged
-> Dioscuri certified
-> sealed
-> mounted
```

A seam never accumulates multiple Smelds. If its contents must grow, Hephaestus reforges one replacement Smeld.

## Remaining build order

### C7 - Motion Body Closure

Forge one continuous Z21-Z23 retrograde-passage body from the final canonical C4 station topology.

Rules:

- use final forged stations as authority
- do not recalculate astronomy
- do not splice the older P22 motion substrate into final truth
- do not split passages at artificial Z boundaries
- preserve one passage from retrograde station to direct station when it crosses a Z seam
- retrograde passages are forged core OrboSpine matter
- exact directional-degree occurrences remain Locate queries; no separate retrograde-crossing table is required for the final coordinate architecture

Add the finished motion body to the OrboSpine candidate and re-close the candidate manifest.

Stop green.

### D0 - Freeze Spine law

Replace consumer-named port identities with the universal Spine ports:

```text
Locate
Library
Link
```

Add the Celestial and Stack Smeld seams, each permitting zero or one certified Spine Smeld.

Do not implement Chronos, Horae, Clotho, or runtime navigation behavior.

Stop green.

### D1 - Locate

Implement compact direct navigation over:

- body / directional degree / UT
- 720-cell navigation projection
- exact station topology
- Terra Marrow by UT

Do not implement external consumers.

Stop green.

### D2 - Library

Expose one stable catalog/addressing seam over the prepared temporal structures already carried by OrboSpine:

- retrograde passages
- stations
- Ring aspect chronology
- eclipses
- F.R.W.Z

Leave the Stack Smeld seam empty.

Do not design Chronos query syntax or behavior.

Stop green.

### D3 - Link

Establish only the common relational addressability required for two or more Spine objects or temporal sets to be related later.

N-way by contract, not pair-only.

Do not implement downstream relationship engines.

Stop green.

### D4 - Assemble

Produce one coherent runtime OrboSpine containing:

- Bone
- Eleven celestial tracts
- supports
- exact stations
- continuous Z21-Z23 retrograde motion body
- Ring occurrences
- eclipses
- F.R.W.Z shells
- Terra Marrow
- Locate / Library / Link access seams
- empty Celestial Smeld seam
- empty Stack Smeld seam
- provenance and source bindings

Stop green.

### D5 - Assembly proof

Prove that assembly preserved:

- all canonical counts
- station topology
- retrograde passage boundaries
- chronological ordering
- Ring occurrences
- eclipses
- shell intervals
- Terra source seams
- Locate addressing
- Library catalog integrity
- Link addressability
- zero-or-one Smeld seam law
- provenance / hashes

No astronomy recalculation.

Stop green.

### E - Dioscuri certification

Independent Castor/Pollux traversal and resonance against the assembled candidate.

### F - Three-Z adversarial proof

Attack seams, stations, reversals, sparse regions, Ring contacts, eclipses, shells, Terra seams, reverse queries, and pathological topology.

### G - Hephaestus final seal

Seal OrboSpine 1.0 only after Dioscuri certification and adversarial proof.

## Governing law

```text
Forge truth once.
Navigate it many ways.
Leave controlled seams for what we learn later.
```
