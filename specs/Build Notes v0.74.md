# v0.74 build notes — the register pull-up

## What shipped
- **Register model for the pull-up** (`_restingLens`, `_plateChart`, `_specRows`,
  `_sheetDataPlate`, `_sheetDataRete`): default face is now register A — the plate chart's
  own body-by-body specifics (position/house/dispositor), re-rendering live when the plate
  changes. Register B (the rete, in itself) is a peer tab. Register C (contact) follows the
  rete: sky → Transits + Lunar, person → Synastry, no one → nothing. New `viewChips` builds
  this row dynamically instead of the old fixed four-tab switcher.
- **Depth control relocated**: removed the four duplicated plain/studied/scholarly chip rows
  from the transits/lunar/election/synastry sheets; one global control now lives on the ♋
  Moon tabula ("reading depth").
- **Electional relocated**: ♏ tabula renamed Releasing → **Timing**, now hosts a "when should
  I… — windows →" entry beside Zodiacal Releasing. Removed the ambient "when should I…" links
  from the sky and transits pull-up feeds — windows is reached deliberately, not ambiently.
- **Copy pass**: seat-card and plate/rete-picker subtitles now read "natal composite" /
  "synchronic · you × now" instead of "minted composite · frozen", matching the locked
  vocabulary (see below).

## Vocabulary — locked, but only half-applied
Locked terms: **Synchronic Composite** (you ⊕ now, live) and **Natal Composite** (midpoint of
two natal charts, minted). This pass renamed all **user-facing copy** to match. It deliberately
did **not** rename the underlying state/code: `abComposite`, `abWith`, `compAB` are still the
internal names for what the UI now calls "Natal Composite," and `composite`/`this.comp` still
back "Synchronic Composite" in code and comments.

Reason: `abComposite`/`abWith` are persisted to `localStorage` (`_persist`); renaming the keys
outright would silently drop that field for anyone with existing saved state, for no
user-visible gain. A real internal rename needs a migration shim (read old key if new key
absent) — not done here, flagged as its own follow-up pass, not bundled into this redesign.

Net effect right now: **the code and the UI use different names for the same thing.** Anyone
reading the source after this point needs to hold `abComposite = Natal Composite` and
`composite/comp = Synchronic Composite` as a translation table until the internal rename
happens.

## Not done this pass
- Internal key rename + migration shim for `abComposite`/`abWith`/`compAB` → Natal Composite.
- Full plate/rete symmetry, Natal Composite as a rete occupant (still open per the reconciliation spec).
- Depth toggle's placement (♋ Moon tabula) was a judgment call, not re-confirmed with the user.
