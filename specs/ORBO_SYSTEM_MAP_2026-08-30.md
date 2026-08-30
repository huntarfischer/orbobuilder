# Orbo System Map — 2026-08-30

**Branch:** `orbo/8-30-26`  
**Baseline:** `b76db2c4`  
**Status:** Dated living-system record

This document records the Orbo system as it exists on the 2026-08-30 consolidated branch. It is descriptive, not aspirational.

## 1. System Shape

```text
                                   ORBO
                                    |
                    +---------------+---------------+
                    |                               |
                  Atlas                           Hermes
          terrestrial orientation          process + announcement routing
                    |                               |
                    +---------------+---------------+
                                    |
                                  Moirai
                    +---------------+---------------+
                    |               |               |
                  Clotho         Lachesis         Atropos
                 natal cast      Titan pass       QC / seal
                    |               |               |
                    |       +-------+-------+       |
                    |       |       |       |       |
                    |     Themis   Rhea   Oceanus  Asteria
                    |     Tympan   Mater    Ring     Arc
                    |
                    |        Hestia / Hearth
                    |        accepted Tapestry
                    |
                    +-------------------------------+

                        MUNDANE TIMESPINE
                         shipped + sealed

                 Horae          Chronos          Hecate
                   |               |               |
                Door I          Door II         Door III
                   |               |               |
                 Locate          Library           Link
                   +---------------+---------------+
                                   |
                           MUNDANE TIMESPINE
```

The Mundane Timespine is forged and sealed program matter shipped with Orbo. It is not created during onboarding.

There is no fourth system-facing route to the Mundane Timespine.

`OrboSpineRuntime`, Bone, Locate, Library, Link, forged tables, candidate manifests, and sealed Timespine matter remain internal to the Timespine boundary.

## 2. The Three Doors

The three doors answer three different questions.

```text
Door I    STATE
          Horae / Locate
          "Show me this moment."

Door II   CHRONOLOGY
          Chronos / Library
          "Find me when."

Door III  RELATION
          Hecate / Link
          "Relate these established coordinates."
```

> **Horae reveals a state.  
> Chronos enumerates its times.  
> Hecate reveals a relation.**

### Door I — Horae / Locate

Door I reveals the Timespine at one requested temporal coordinate.

```text
requested moment
      |
    Horae
      |
   Door I
      |
    Locate
      |
Timespine cross-section
```

Horae carries outward canonical Timespine state. Horae does not calculate or refine Timespine truth.

**Current status:** `CONNECTED`

### Door II — Chronos / Library

Door II searches and navigates chronology.

```text
factual temporal predicate
          |
       Chronos
          |
       Door II
          |
       Library
          |
zero / one / many temporal addresses
```

Chronos returns ordered temporal addresses where a factual predicate is true. Chronos does not create relational truth.

**Current status:** `CONNECTED`

### Door III — Hecate / Link

Door III is the relational entrance to addressed Timespine matter.

```text
established coordinate A
established coordinate B
          |
        Hecate
          |
       Door III
          |
     Link / LinkSet
```

The permanent division is:

```text
Link / LinkSet
-> addresses the Timespine matter

Hecate
-> conducts the lawful relationship
```

Link does not calculate relationships. Hecate does not become a Timespine storage or addressing authority.

Not every Hecate operation uses Door III. Hecate may cast from resources directly placed in her hands. Door III is specifically Hecate's relational entrance to Timespine matter.

**Current status:** `CONNECTED` — `HecateLink` reads existing `SpineLinkSet` truth through Door III without creating relations, expanding N-way links, or exposing `OrboSpineRuntime`.

## 3. Natal Path

The intended living natal path is:

```text
birth facts
   |
 Atlas
   |
Topos + Tempus
   |
 Clotho
   |
 Horae
   |
Door I / Locate
   |
Mundane Timespine
   |
celestial state + Terra
   |
 Clotho
   |
 Hecate
   |
Ascendant + AstroDNA + chart truth
```

Clotho's existing Door I contract is correct in shape. The production Clotho-to-Horae seam remains a bounded follow-up pass.

## 4. Moirai and Titans

The Moirai own the engraving process, not the Titans' truth.

```text
Clotho
-> gathers natal thread / chart matter

Lachesis
-> petitions the Titans directly

Themis
-> Tympan testimony

Rhea
-> Mater testimony

Oceanus
-> Ring testimony

Asteria
-> Arc testimony

Atropos
-> compares finished Tapestry against its required truth
-> accepts or rejects
```

No Titan receives another Titan's testimony. Each Titan creates its own view when petitioned. Lachesis combines their testimony.

## 5. Hermes and Hestia

System routing law:

```text
QUESTION / CONSULTATION
Orbo -> relevant authority directly

START A PROCESS
Orbo -> Hermes -> routed process

ANNOUNCEMENT
Orbo -> Hermes -> intended audience
```

Hermes is courier, manifest, and messenger authority. Hermes is not a generic service bus.

Hestia is keeper of the Hearth. She receives the special completed package, accepts or rejects it according to her law, and keeps accepted native truth. She is not a generic astrology calculator.

## 6. Pantheon

The broader living Pantheon on this branch includes:

- **Hephaestus** — forge / construction authority
- **Dioscuri** — certification / paired proof authority
- **Iris** — visualization authority
- **Aether** — living Orbo authority at its current MVP boundary
- **Apollo** — living Orbo authority at its current MVP boundary
- **Artemis** — living Orbo authority at its current MVP boundary
- **Pythia** — `INTENTIONALLY FUTURE`; declared authority whose deeper timing work is not yet built

`INTENTIONALLY FUTURE` does not mean broken.

## 7. Foundation and Runtime Law

The sanctioned deep manufacture path remains:

```text
Ephemeris
   |
 Forge
   |
Mundane Timespine
```

Normal Orbo runtime reads the shipped Mundane Timespine. It does not reopen the Ephemeris or use Forge as a runtime oracle.

All system-facing Timespine use is therefore:

```text
STATE       -> Horae   -> Door I
CHRONOLOGY  -> Chronos -> Door II
RELATION    -> Hecate  -> Door III
```

## 8. Open Seam at This Date

This map records one bounded connection gap for the next pass:

1. **Natal Door I:** establish the production Clotho -> Horae seam for Clotho's existing Door I request.

This is a connection gap, not an invitation to redesign the surrounding authorities.

## 9. Date Law

This map belongs to `orbo/8-30-26`.

Future architectural changes should be recorded against the dated Orbo branch on which they become accepted, so this document remains a truthful snapshot rather than a moving target.
