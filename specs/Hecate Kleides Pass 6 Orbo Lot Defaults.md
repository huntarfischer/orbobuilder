# Hecate Kleides — Pass 6 Orbo Lot Defaults

Status: design/doctrine freeze only. No Swift changes.

## Purpose

Pass 6 does not choose a new Lot tradition. It reconciles the new Kleides catalogue with doctrine already established in the older Orbo engines.

Three repo witnesses agree:

- `packs/Orbo Traditions.md` sets sect-reversed Fortune and Spirit as Orbo defaults and names the core Lot framework as Valens + Paulus.
- `astrodna.js` declares the app's Hermetic Lots as one formula in one place.
- `zr.js` names that operating family Pauline/Hermetic and gives the same day/night formulas.

The new catalogue correctly taught us that Valens' principal Eros and Necessity are distinct astrological Lots from the later planetary/Hermetic Eros and Necessity. Orbo's old operating formulas belong to the latter pair.

## Frozen first-four Orbo defaults

All results normalize to Orbo's canonical 0..<360 ring.

### Fortune

Identity: `Fortune`

Requirements: `Asc`, `Moon`, `Sun`, `Sect`

Day:

`Asc + Moon - Sun`

Night:

`Asc + Sun - Moon`

Sect rule: reverse

Orbo default catalogue witness: `Mainstream Hellenistic / Valens`

The Ptolemaic same-direction variant remains available but is not Orbo Default.

### Spirit

Identity: `Spirit`

Requirements: `Asc`, `Sun`, `Moon`, `Sect`

Day:

`Asc + Sun - Moon`

Night:

`Asc + Moon - Sun`

Sect rule: reverse

Orbo default catalogue witness: `Hellenistic mainstream`

The al-Biruni / Abu Ma'shar duplicate witness remains provenance, not a second Orbo default.

### Eros

Orbo's L1 identity is the Pauline/Hermetic planetary Eros associated with Venus, not Valens' principal Eros.

Requirements: `Asc`, `Venus`, `Spirit`, `Sect`

Day:

`Asc + Venus - Spirit`

Night:

`Asc + Spirit - Venus`

Sect rule: reverse

Tradition label: `Pauline/Hermetic`

Source basis for the exact Orbo formula: existing Orbo engine doctrine in `astrodna.js` and `zr.js`. The new Lots research report identified the planetary Love/Venus identity but did not itself supply this exact formula, so Pass 7 must preserve that provenance distinction rather than pretending the report supplied it.

### Necessity

Orbo's L1 identity is the Pauline/Hermetic planetary Necessity associated with Mercury, not Valens' principal Necessity.

Requirements: `Asc`, `Fortune`, `Mercury`, `Sect`

Day:

`Asc + Fortune - Mercury`

Night:

`Asc + Mercury - Fortune`

Sect rule: reverse

Tradition label: `Pauline/Hermetic`

Source basis for the exact Orbo formula: existing Orbo engine doctrine in `astrodna.js` and `zr.js`. The new Lots research report identified the planetary Necessity/Mercury identity but did not itself supply this exact formula, so Pass 7 must preserve that provenance distinction rather than pretending the report supplied it.

## Identity reconciliation

The current Pass 5 catalogue has these six pages:

- `Fortune`
- `Spirit`
- `Eros` — Valens principal-lot formula
- `Necessity` — Valens principal-lot formula
- `Planetary Love (Venus)` — Paulus-line identity, exact formula unresolved in the research report
- `Planetary Necessity (Mercury)` — Paulus-line identity, exact formula unresolved in the research report

Pass 7 shall reconcile them without collapsing identities:

- `Fortune` stays `Fortune` and remains `T/T/T`.
- `Spirit` stays `Spirit` and remains `T/T/T`.
- the planetary/Hermetic Venus page becomes the canonical Orbo `Eros` page and becomes `T/T/T`.
- the planetary/Hermetic Mercury page becomes the canonical Orbo `Necessity` page and becomes `T/T/T`.
- the existing Valens principal-lot `Eros` page becomes `Valens Eros` and becomes `F/F/T`.
- the existing Valens principal-lot `Necessity` page becomes `Valens Necessity` and becomes `F/F/T`.

Aliases must preserve the old/source names so no historical identity is lost.

## Dependency graph

```text
Asc + Sun + Moon + Sect
        |
        +--> Fortune
        |
        +--> Spirit

Spirit + Venus + Asc + Sect
        |
        +--> Eros

Fortune + Mercury + Asc + Sect
        |
        +--> Necessity
```

Hecate still receives all operands. She does not query or derive missing matter on her own.

## Orbo Default flags

After Pass 7 exactly these formula rows are Orbo Default among the first four:

- Fortune — mainstream sect-reversed formula
- Spirit — mainstream sect-reversed formula
- Eros — Pauline/Hermetic Venus/Spirit formula
- Necessity — Pauline/Hermetic Fortune/Mercury formula

No Valens principal Eros/Necessity formula is an Orbo Default.

## Pass 7 boundary

Pass 7 may:

1. perform the six-page identity/availability reconciliation above;
2. add the exact legacy Orbo Pauline/Hermetic Eros and Necessity formulas with honest repo provenance;
3. mark the four frozen formula rows as Orbo Default;
4. activate casts for Fortune, Spirit, Eros, and Necessity;
5. test Sect, dependencies, exact boundary behavior where relevant, and 0..<360 normalization.

Pass 7 may not activate additional Lots, alter Sect doctrine, touch Clotho, or broaden Hecate's query responsibilities.
