# Rulership and Governance

This note defines shared Orbo vocabulary used across Mater, Tympan, Lachesis, the Tapestry, and later deterministic chart structure.

## Core distinction

**Signs are ruled. Houses are governed.**

### Rulership

Rulership is a universal zodiac relationship:

```text
sign -> ruler
```

A **ruler** is a planet assigned to a zodiac sign by a rulership doctrine.

Rulership exists independently of any selected chart or Ascendant. It belongs fundamentally to **Mater**.

Examples:

```text
Aries     -> Mars
Taurus    -> Venus
Scorpio   -> Mars      (traditional)
Scorpio   -> Pluto     (modern)
Aquarius  -> Saturn    (traditional)
Aquarius  -> Uranus    (modern)
Pisces    -> Jupiter   (traditional)
Pisces    -> Neptune   (modern)
```

### Governance

Governance is the chart-specific house expression of rulership:

```text
house -> governor
```

A **governor** is a ruler acting over a specific house because its sign occupies that house in a selected **Tympan Imprint**.

Tympan does not invent rulership. It applies rulership to the house structure selected by the rising sign.

Thus:

```text
Mater                         Tympan
universal                     chart-specific

sign -> ruler                 house -> governor
rulership                     governance
```

And:

```text
traditional ruler -> traditional governor
modern ruler      -> modern governor
```

## Tympan Imprint

A **Tympan Imprint** is one of the twelve canonical whole-sign house structures, one per rising sign.

Selecting an Imprint establishes:

- house -> sign
- house -> traditional governor
- reverse traditional governor -> governed houses
- modern governance augmentation
- complete house-facing governance reads

No natal planet placement is required for an Imprint to exist.

## Governance Lattice

The **Governance Lattice** is the chart-specific topology produced by traditional rulership across the twelve houses of one Imprint.

Example, Scorpio rising:

```text
Mars      -> Houses 1, 6
Jupiter   -> Houses 2, 5
Saturn    -> Houses 3, 4
Venus     -> Houses 7, 12
Mercury   -> Houses 8, 11
Moon      -> House 9
Sun       -> House 10
```

The lattice records shared governance. It is not interpretation and it does not depend on natal occupants.

## Traditional and modern channels

### Traditional governance

Traditional governance is the canonical governance lattice.

It preserves the classical seven-planet house-governance structure and remains separate from modern augmentation.

Traditional **rulership** is also the canonical backbone used by the classical dispositor graph.

### Modern governance

Modern governance is an explicit augmentation of the selected Imprint:

```text
Pluto   -> house occupied by Scorpio
Uranus  -> house occupied by Aquarius
Neptune -> house occupied by Pisces
```

Modern governance:

- does not replace traditional governance
- does not alter the traditional Governance Lattice
- does not enter the classical dispositor graph
- carries no intrinsic interpretive weighting

Its presence is structural. Any judgment of relative strength belongs downstream.

## Example

For Scorpio rising:

```text
House 1
    sign: Scorpio
    traditional governor: Mars
    traditional governed houses: [1, 6]
    modern governor: Pluto

House 7
    sign: Taurus
    traditional governor: Venus
    traditional governed houses: [7, 12]
    modern governor: none
```

The same universal rulership law therefore becomes different house governance under different Imprints.

## Boundary

This vocabulary describes deterministic structure only.

It does not define:

- natal occupants
- co-presence
- dispositor chains themselves
- interpretation
- weighting between traditional and modern governance
- Ring geometry
- Arc relationships

Those systems may consume rulership or governance, but they do not change what the terms mean.
