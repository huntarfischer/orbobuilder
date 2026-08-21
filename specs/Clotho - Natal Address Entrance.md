# Clotho - Natal Address Entrance

## Purpose

Replace Clotho's current `AstroDNA` entrance with the resolved natal address, while preserving her existing thread and recipe output exactly.

## What the repo already provides

- `CivilTime` resolves civil date/time and timezone to one absolute instant.
- `Place` already carries latitude, longitude, and timezone.
- `MundaneTimespine` returns longitude and motion for the eleven celestial bodies.
- `Ring` converts longitude + motion into the canonical `RingFineState` Clotho already preserves.
- Clotho currently receives a finished twelve-gene `AstroDNA`.

## Missing piece

The Timespine supplies eleven of the twelve AstroDNA genes. It does not supply the Ascendant.

The Ascendant is place-dependent and must come from the native Horizon authority. It must not be smuggled into the new entrance as precomputed AstroDNA.

Therefore the canonical source is:

```text
Resolved Natal Address
    instant + place
          |
          +--> Mundane Timespine --> 11 celestial states
          |
          +--> Horizon -----------> Ascendant
                                     |
                                     v
                                  Clotho
```

## Smallest build sequence

1. Add one canonical `NatalAddress` value containing only:
   - `AbsoluteInstant`
   - `Place`

2. Prove that the address supplies the same instant and place unchanged. No new civil-time mathematics.

3. Build the smallest Horizon surface required to return one exact Ascendant longitude from `NatalAddress`.

4. Prove Horizon independently against trusted reference fixtures before Clotho uses it.

5. Add a new Clotho entrance that receives:
   - `NatalAddress`
   - `MundaneTimespine`

   Clotho gathers the eleven Timespine bodies, receives the Ascendant from Horizon, converts all twelve through `Ring.fineState`, and then performs her existing thread + recipe operation.

6. Prove the new entrance produces the same twelve threads, order, exact states, degree addresses, and recipe as the existing AstroDNA-fed path for the same nativity.

7. Only after parity is proven, retire the direct `AstroDNA` entrance from the canonical Moirai route.

## Non-goals

No Hermes changes.
No Lachesis changes.
No Atropos changes.
No Hestia work.
No new ephemeris.
No duplicate planetary calculation.
No rectification work.
No redesign of AstroDNA.

## Acceptance criterion

The next architecture is proven when:

```text
NatalAddress
    -> Timespine + Horizon
    -> Clotho
    -> the same canonical twelve-thread packet and recipe
```

as the already-proven AstroDNA-fed Clotho path.
