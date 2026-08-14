# PROFECTIONS
## Canonical Source Text

*Alan Leo's Dictionary of Astrology*  
Edited by Vivian E. Robson  
1929

> Clean transcription of the **Profections** entry from the photographed printed pages, checked against the OCR text. Historical wording and doctrine are preserved. Computational interpretation is kept in the separate Orbo Profections Engine.

---

# PROFECTIONS

Equal and regular progressions of the Sun and other significators in the Zodiac, allowing to each profection the whole circle and one sign over; as, if the Sun in the first year be in 30 degrees of Aries, the next year it will be in 30 degrees of Taurus; and so on.

Briefly we proceed as follows: Number the years from birth to the one for which the profectional directions are desired to be taken, and for every year add one sign to each of the signs containing the Hyleg, the Sun, the Moon, the Ascendant, and the Meridian at birth.

The lord of the sign so deduced from the place of the Hyleg is the chronocrator for that year.

Note that the computation is made from the degree of the sign holding the Hyleg, therefore the term may include portions of two signs.

Thus if it be required to find the annual chronocrator for the twenty-seventh year, the Hyleg at birth being in 2° ♎ 13′, we see that from 2° ♎ 13′ to 2° ♏ 13′ would be the ruling period for the first year, and from 2° ♏ 13′ to 2° ♐ 13′ that for the ensuing year, so that for the twenty-seventh year a progression through the various signs of the zodiac would have been completed twice before arrival was made again at the point required, viz., 2° ♐ 13′ to 2° ♑ 13′, the lords of which signs are the actual chronocrators for the year.

Having determined this point, the monthly profection may be acquired therefrom in this manner: Allow twenty-eight days for the month, and for every month after natal month add one sign, counting from the sign of the year.

To the days may be also apportioned their rulers, if desired, by allowing a sign for every two days and eight hours after birth, still keeping to the month of twenty-eight days, and counting from the day of the month on which the birth occurred.

Judgment is arrived at by a judicious combination of the several elements as they stand. The annual sign and its rulers will exhibit the general influence for the year, and the monthly places the equivalent monthly influences.

Notice, however, is to be paid to the representation of these places in the radix, both as regards sign and planet and their position by this progressed motion in regard to the ascendant, M.C., etc.; also what planets, if any, are at the time of profection passing by transit through such signs ruling the year or month.

That these profections have a value seems pretty evident, and Raphael has somewhere said that he is inclined to discredit the usual forms of directing in favour of them, believing that everything runs in cycles.

There is no doubt an element of truth in this, but all we can say in the present state of our knowledge is that their principal use would appear to be in supplying media for primaries and secondaries to function in.

---

# COMPUTATIONAL STRUCTURE PRESENT IN THE SOURCE

This section is an index to the source rules, not additional doctrine.

| Level | Source operation |
|---|---|
| Annual | Advance each significator one zodiac sign for each year |
| Annual points | Hyleg, Sun, Moon, Ascendant, Meridian |
| Annual chronocrator | Lord of the sign deduced from the Hyleg |
| Exact degree | Preserve the natal degree while advancing by signs |
| Annual term | Runs from the profected degree in one sign to the same degree in the next sign, so a term may include portions of two signs |
| Monthly | 28-day periods; advance one sign per month from the sign of the year |
| Daily subdivision | One sign per 2 days 8 hours within the 28-day month |
| Judgment context | Combine annual and monthly places with the radix, Ascendant/M.C. relationships, and transits through ruling signs |
| Stated function | Profections may supply media through which primaries and secondaries function |

## Preservation note on year numbering

The printed example defines the **first year** as the interval beginning at the natal Hyleg and ending one sign later. Therefore:

- Year of life 1 begins at the natal position.
- Year of life 2 begins one sign later.
- Year of life 27 begins twenty-six signs after the natal position.

The accompanying engine uses this explicit **year-of-life** convention and also provides an `ageYears` convenience in which `ageYears = 0` corresponds to year of life 1.

## Preservation note on chronocrators

The entry first speaks of “the lord of the sign” as the chronocrator, but then emphasizes that the exact-degree annual term may contain portions of two signs and says that “the lords of which signs are the actual chronocrators for the year.”

The engine therefore preserves both levels:

1. the ruler of the sign at the start of the annual profection; and
2. every sign/ruler actually traversed by the exact 30° annual term.

It does **not** invent a numerical weighting or priority between those rulers.

---

# END OF PROFECTIONS
