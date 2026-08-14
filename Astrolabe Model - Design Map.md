# Composite Framing — The Astrolabe Model
*Design map, captured from conversation. No code changed. A thing to react to, not a spec to build yet.*

---

## THE LEXICON — canonical names (July 16, 2026, from the user, verbatim intent)

**The Astrolabe — the Luminary of Orbo.** The light source.

**The Aegis — the face of the Astrolabe.** Consists of the **Rete** (outer ring) and the **Plate** (inner ring) upon which the bodies orbit, and the engraved **Ring**.

**The Bodies** — the planets and objects on the Aegis function as the hands of the clock. ASC/angles ≈ 1 day (hour hand) · Moon ~27d · Mercury/Venus/Sun months · Mars ~2y · Jupiter ~12y · Saturn ~29y (generational). Fast body = fine time; slow body = coarse time.

The Aegis defaults to **live time**. Tap center = play/pause at a faster clip · hold center = **mark the moment** (Person / Event / Horary; "mark + calendar" = .ics).

**The Big Three** — elemental Asc, Moon, Sun: the most prominent measure of time, front and center above the date/time and the alidade.

**Rule / alidade** — "who + when": the time-hand + the who-selector, the two things you point.

**Horizon lock** — grab the horizon (ASC) to scrub the day; plays in minutes/sec vs hours/sec free. Double-tap As = horizon lock · double-tap clock = home (now) · double-tap rim = flip to the Tabula.

**The Lunar Pane** — refracts the light from the bodies on the Astrolabe. Dormant at the bottom of the screen until called for; rises and eclipses the lower part of the Astrolabe. By default it contains the specifics of the charts on the Rete and the Plate (natal chart, the sky, transits). The Lunar Pane has its own Rete (menu) and Plate (sub-menus): arc'd categories, scrollable, expanding and contracting as needed — more interpretations of the Astrolabe's light, controlled via the Tabulas on the back. The user can **fuse** more ways to refract the light into the Lunar Pane via the Tabula.

**The Tabula** — the back of the Astrolabe, reached by double-tapping the outer ring. Twelve Tabulas (menus) controlling the entirety of Orbo, sorted by the domains of the twelve signs:

- **♈ Natal chart** — engrave the Tabula with your birth data: name, date, time, birthplace (city typeahead); the natal-visibility toggle.
- **♉ Here & now** — your location: "use my location" or type a city; the here-and-now default.
- **♊ Planets** — the ten planet toggles (circular chips) **and Objects**.
- **♋ Moon** — phase, illumination %, sign, next ingress, void-of-course, mansion; the lunar-transits ("fast hand") lens. **Reading Depth: Plain / Studied / Scholarly.**
- **♌ Appearance** — the wheel's look: decan faces (off/engraved), rim metal (none/brass/silver).
- **♍ Aspects** — orb slider; which aspects (5 majors + 9 minors, each toggleable) appear on the Astrolabe.
- **♎ THE LEDGER** — the roster where the user enters the information: people (natal), events, horary; entry field; add/manage.
- **♏ Timing** — releasing / time-lord techniques (ZR, profections, electional astrology).
- **♐ THE ALMANAC** — calendar that can be added to the Lunar Pane, to which the user can fuse Timing.
- **♑ Gears** — app settings; transport: play speed, rim gearing, snap magnetism, haptics.
- **♒ Archive** — memory: pinned/marked moments.
- **♓ Compositry** — composite framing: engage the plate, choose the pairing (you × moment, you × person, person × person).

**Status: this lexicon describes the app as built** (verified against `Orbo Astrolabe.dc.html`, July 16). The Tabula's twelve slots (Natal · Here·Now · Planets · Moon · Image · Aspects · Ledger · Timing · Almanac · Gears · Archive · Framing), reading depth, the lunar-transits fast-hand lens, the Lunar Pane with its arc'd menu (the Sky / Transits / …), Composite Chronology — all live. This section is the canonical vocabulary for talking about them, consistent with the sun/moon law: the Aegis is the light; the Lunar Pane refracts it; the Tabula is the maker's side.

Two naming drifts between lexicon and build labels: ♌ reads **Image** on the rim (lexicon: Appearance) and ♓ reads **Framing** (lexicon: Compositry).

---

## North star

> ## The solar system is the clock.

Everything else is measured against this. A timestamp — "12:48pm Monday" — is a lie of convenience: a human label slapped onto a unique arrangement of the heavens. The real address of any moment is its *configuration* (Sun, Moon, and planets at their positions). Clock-time is the derived shadow; the sky-state is the truth. When a design decision is unclear, the one that treats the sky as the clock wins.

---

## The one-line idea

**One instrument, two faces. A front you *play* and a back that *is you*. You navigate by grabbing a thing to promote it to the thing that drives. The gears are cut by the real sky. Time is the film; your thumb is the transport.**

Everything below is just that sentence, unpacked.

---

## Why we're doing this

The app today is **three navigation layers deep**: top tabs → sub-views → in-panel mode pills (the 4 wheel modes, per-tab person toggles, per-tab body toggles). To reach one view you make three sequential choices, and controls get re-instantiated per tab. The astrolabe metaphor isn't decoration — it's the argument for collapsing all of that into **two gestures plus a scrubber.**

An astrolabe is *not* a set of screens. It's **one object, one center pin, one shared frame**, and you get answers by stacking transparent layers and reading across them. That's the opposite of tabs.

---

## The two faces

### FRONT — the instrument you play
- The honest chart wheel. **Planets sit in their true positions** — the wheel stays astrologically truthful; we never rearrange it to make a tidier control.
- You **never type here.** It's grab-and-scrub, thumb-driven, gestural.
- Ungrabbed, it just runs on plain **calendar/solar time** (the default hand). No configuration to start.

### BACK — you (reached by **double-tap to flip**)
- The back is **you**: your natal chart, entered once at setup, and your **geolocation defaulting to here-and-now.** The plate is cut for *your* latitude, *your* birth.
- "Full setup, but not the full setup" — it holds only the **invariant** (you + your here-now), not a settings drawer, and *not* the roster of other people.
- Set once, rarely revisited. Precise numbers and specifics live here, away from the playful face.

**Consequence — there is no empty state.** Because your natal is baked in at setup and geolocation registers the here-and-now, you open the app and *you are already there*: already the center, sky already running. You never start from nothing — you only add layers to an already-live you. You don't "load" the instrument, you pick it up.

---

## The sky-vector has two halves — universal & local

Every moment's true address splits in two:

- **Universal** — the planetary longitudes (Sun included). *Same for everyone alive at that instant.* This is the shared substrate — the collective clock.
- **Local** — the angles, **ASC / MC**. These depend on *where you're standing*, so they're *yours alone.*

**The Ascendant is the hand that localizes the universal clock to you.** Everyone on Earth shares "Mercury 24° Cancer Rx" right now — but your horizon is yours. That is *why* "back = you, here-and-now, geolocated" is load-bearing and not a convenience: without your place, the universal clock has no *local* reading. The universe gives everyone the same sky; the ASC is how it becomes *your* moment. It's also the fastest hand (Earth's rotation, ~1 rim-sweep = 1 day), so grabbing the horizon is grabbing the day itself.

---

## The one gesture: **promote**

The whole app has essentially **one core interaction**, expressed differently depending on what you touch:

- An **edge** promoted to a **plate** → *compositing* (bring someone in as an overlay held *against* you, then fuse them into a plate you stand on).
- A **planet layer** promoted to the **transport** → *isolate-and-track* (a body stops being a dot and becomes the clock).

"Composite" carries this in both crafts at once: **astrologically** = the midpoint fusion of two charts; **cinematically** = flattening layers into one image. Same word, same gesture.

---

## Two axes of change (orthogonal)

1. **Temporal — the film.** Cinema, not "animate mode." Every assembled stack is a single *frame*; stepping the date advances the frame and the whole instrument re-renders. Time isn't a layer — time is the film. The old date-stepper, the Timeline tab, and "animate chart" all collapse into **one transport.**
2. **Compositional — the stack.** Bring someone in as an edge, fuse to a plate. A verb you perform, not a tab you visit.

The four old wheel-mode pills (Synastry / Natal overlay / Composite overlay / A×B) were never four unrelated views — they're **stops along the edge→plate promotion.** Two rings = pure edge; overlay = pressed closer; composite = fully fused.

---

## The gearbox — bodies as the hands of the clock

You never pick a time unit from a menu. **The object *is* the interval.** Selecting a body engages its gear, and its speed is the *true ephemeris*, not an arbitrary mapping.

> **One full sweep of the rim = one full orbit of the body you're holding.**

- **ASC / angles** — Earth's *rotation* (grabbing Earth's spin, not a planet's orbit) — 1 rim ≈ **1 day** (hour hand)
- **Moon** — ~27 days
- **Mercury / Venus / Sun** — months
- **Mars** — ~2 years
- **Jupiter** — ~12 years
- **Saturn** — ~29 years (generational hand)

**Fast body = fine time; slow body = coarse time.** You change temporal resolution just by touching a different dot. Grab the Moon and a thumb-move is hours (catch a transit to the day); grab Saturn and it's years (pan the long arc). This is what a geared astrolabe / orrery physically *was* — a train of wheels cut to planet-true ratios.

**Aspects to your digit.** While you hold a body and scrub, its aspect threads stay live and **radiate from your fingertip** — squares and trines bloom and dissolve around your thumb. You *feel* the body enter and leave relationship. This is the moment it stops being an app and becomes an instrument you play — and the whole reason phone-first is right.

---

## The touch grammar — zone × gesture

The chart's **concentric rings are already a nested set of input zones** ("outer edge vs inner" is literal anatomy, not metaphor). Phone-first: the wheel fills the top ~⅔, its rim sits in the thumb arc.

| Zone | Tap | Hold / scrub |
|---|---|---|
| **Outer tick ring** | — | scrub = fine time (even glide) |
| **Sign ring** | — | scrub = coarse time (month/season, even glide) |
| **House / ruler ring** | filter tables to that house | *(open: isolate its ruler?)* — structural time, snaps event-to-event |
| **Planet ring** | drill into that body | isolate → body becomes the clock, snaps aspect-to-aspect |
| **Center (the "dead space")** | **play / stop** | **hold = composite / layer menu** |
| **Lock** | deliberate gesture (double-tap center, or edge toggle) — freezes input while it animates |

**Two scrub feels, assigned by ring:** even rings *glide* (a minute is always a minute); isolated-body and ruler rings *snap* — magnetic to the next real event (aspects/ingresses aren't evenly spaced; they land when things actually happen).

**Dead space is a benefit, not waste.** A big empty center is a fat-finger-proof target *and* semantically where aspect lines converge — the right home for play/stop and for the fuse verb, performed right where the threads between bodies live.

**Double-tap = flip to the back** (enter specifics). Otherwise you just grab and scrub.

---

## The layer stack (astrolabe → app)

- **Back** = your natal chart (the same-center invariant) — geolocated to here-and-now, entered once. The back is also literally the *table* side on a real astrolabe, so the reference readouts belong to it conceptually.
- **Plate** = the composite frame. Plates are **swappable** — one per partner, one per moment. Digital plates can *stack* translucent (composite + a moment) where brass could hold only one.
- **Edge** = transits / synastry / overlay — the contextual ring you read the stack against, *before* compositing fuses it into a plate.
- **Rete (moving heaven)** = the live composite/transit positions for the chosen frame — the dots that move as you scrub.
- **The rule / alidade** = **who + when** — the two things you point. On a phone: the time hand (the grabbed body) + the "who" selector.

---

## Layout, phone-first

- Wheel fills the top; **rim = thumb transport.**
- **Center tap = play/stop; center hold = composite / layers.**
- **Information lives in a pull-up sheet** (there's no "below" on a phone until you ask): the lens readouts + layer stack + the *composite* verb. Drag up for depth, down for the full wheel.
- **Tapping a body/house raises the sheet to that detail** — the wheel becomes the index into the tables, i.e. the navigation itself.
- **Tabs = lenses** (positions / arcs / rulers-dispositors / aspects) — they re-inscribe the *same* wheel; they never replace it. **The discipline that keeps this from regressing into the old tabs: the instrument persists and stays continuous; a tab changes only what's emphasized on it and what table sits beneath it.**

---

## Still open (to resolve before it's a build)

1. **The roster entry point.** Adding people is front-side (part of compositing, not back-side setup). How does the roster surface, and how do you promote someone **roster → edge → plate**? This "who" pairs with the time hand as the rule (who + when). *Only major piece not yet drawn.*
2. **Hold actions on house / planet** — one strong secondary action per object. (Isolate its arc? Start a comparison edge?)
3. **Relocation** — the back sets default place; can the front override place ("what if I were in Tokyo")? That's swapping the plate for another latitude — latent feature, maybe out of scope.
4. **Two-observer tension** — a real astrolabe has one observer. Synastry = two retes on one plate. Confirm the single-center model holds (composites are midpoints on one wheel, so it should).
5. **Event capture.** The instrument's whole purpose is *finding timing* — so once a moment is locked and its aspects read, one gesture should mint it as an **event**: saved in the astrolabe (the back's events list already holds them) **and exported to the calendar** (ICS / calendar API). Front-side "capture this moment" gesture + calendar export not yet built.

---

*Reactions welcome on this doc directly.*

---

## State of play (July 6, 2026)

- **`Gearbox Prototype.dc.html` is built and validated** — the feel test passed ("felt the jolt"). Wheel + grabbable hands (ASC/all planets, gear cut to *time* so retrogrades loop honestly), live aspect threads to the held body, center-tap play/stop, sky-address primary / civil-time secondary readouts. Tweaks: orb, aspect web, play speed.
- **Prototype caveats:** location hardcoded (Richland Center) pending back-side geolocation; time clamped 1800–2050 (engine validity); no event-snap, plates, people, bottom sheet, flip, or lock yet.
- **Engines survive as-is:** `ephem.js` (sky-vectors: `positions(jd)`, `angles(jd,lat,lon)`), `framing.js` (composite fusion). The rebuild is a re-facing, not a rewrite.
- **Ideas not yet folded into this map** (from conversation, still live): the natal seed *unspools* into a personal timespine (transits/ZR/profections as biographical gears; nested releasing rings); a composite is a *new seed with its own strand*; "field, not chart" — one operation, light mixing with light, at four pairings (× now / × person / × event / → new seed); Timespine = the backend both this app and Orbo sit on; this app = connecting to astrology itself, Orbo = connecting to people through it.
- **Sensible next steps** (pick one): event-snap magnetism on the held hand · the bottom sheet (tables + lenses) · the back (flip, geolocation, natal entry) · roster → edge → plate (the composite verb).

## State of play — RECONCILED (July 9, 2026)
*A full code audit corrected the drift below: several items the older logs list as "next" were already built. Current truth for `Orbo Astrolabe.dc.html`:*

**Done and verified:**
- **Back rim + all twelve panels** exist. ♈ Natal · ♉ Here & Now · ♊ Planets · **♋ Moon** (phase canvas, illumination %, sign, next ingress, tap-to-jump to next new/full — VoC still reads "coming soon", mansions unbuilt) · ♌ Appearance · ♍ Aspects · ♎ People (roster) · ♏ Objects · ♐ (Lenses, dormant) · ♑ Gears · ♒ Events · **♓ Composite Framing** (was the blank slot; now the composite's home).
- **♊ Planets & ♏ Objects use circular toggle chips** (round 25–29px, wrapping centered flex) — the old rectangular-grid overflow is gone. *Not* yet arranged in a literal ring around the disc (optional refinement).
- **Objects roster complete**: Nodes, Lilith, Chiron, **Ceres/Pallas/Juno/Vesta** (osculating Kepler, M0 corrected against JPL), **Part of Fortune** & **Vertex** (need asc, computed alongside). Ephemeris + toggles + rendering verified against published 2026 positions.
- **The plate (natal-as-plate)** — engraved stone, zodiac-true, at rN = rBody−17. Threads + snap to natal, "to you" sheet lens, all live.
- **♓ composite steps 1–2**: engine lift (`_updateComposite` → `this.comp`/`compArc`/`compFlip` per jd) and resting beads (gilt points on faint channels) + the ♓ panel.

**Genuinely remaining** (all the plate becoming *interactive*, unblocked by the hit-map groundwork):
- **♓ 3** held-bead mechanics (grab at half-gear, channel lighting, flip stops + pulse) — Fable.
- **♓ 4** cAs rim arc with stops + daily-anchor gesture — Fable.
- **♓ 5** composite-bead threads (bead↔bead gilt), snap to bead/flip, composite lenses (to-flip countdown, in-composite aspects, overlap readings) — *note the sheet's four lenses already exist but serve held transit-body→natal, not beads.*
- **♓ 6** person plates / B-plate / synastry — later.
- **#9** tap a natal engraving → its reading (hit-testing) — *in progress July 9, see below.*
- **Polish**: **DONE (July 11)** — real Moon VoC (last-aspect-before-ingress scan) + mansions; optional radial chip ring remains open.

*Foundation laid July 9: the draw now keeps two hit-maps — `this._natalScreen` (engraving screen coords) and `this._beadScreen` (composite-bead coords) — reset and repopulated each frame, parallel to `this._screen` for transit bodies. `_down` consults `_natalScreen` (after transit bodies, which keep priority): tapping a natal engraving opens **#9's natal reading** — a sheet reading "your ☽ Moon" with its natal signification (sign · whole-sign house from natal As · dispositor) and current transits-to-it (`_sheetDataNatal` / `_transitsToNatal`; sheet flagged `natal:true` so the live-refresh in `_tick` rebuilds the right kind). `_beadScreen` is populated but not yet grabbable — that hookup is ♓ 3 (Fable).*

*Fable runway laid July 9 (♓ 3 prep — snapshot `Orbo Astrolabe v4.dc.html`, brief `Fable Brief — Composite Held-Bead (Pisces 3).md`): with Fable's budget ~88% spent, all non-feel plumbing for the held bead is done so Fable spends its last ~12% purely on look/feel. Bead **grab is wired** (`_down` sets `this.held = 'bead:<key>'`, read via `this._heldBeadKey()`), scrub runs at the correct **half-gear** (bead = midpoint → moves ½ the transit rate; `_move` uses `2× PERIODS`, verified a bead-drag scrubs jd exactly 2× the transit-hand equivalent), snap-magnet skipped for beads (→ ♓5), the `_tick` long-press-reading guard excludes bead tokens, and `_draw` exposes `heldB`/`isHeld` with a placeholder brighten for Fable to replace with the real held treatment (channel ignition + flip-stop glow + pulse on `this.compFlip`). **♓ 4 (cAs rim arc) reassigned from Fable to main/Opus** — once ♓ 3 sets the bead language, the arc is more geometry than feel, and the As-bubble/horizon/plate geometry is now well-trodden. Known tension flagged for Fable: beads sit 17px inside the transit ring, so transit hit-priority (30px) can shadow a bead grab — an interaction-priority call left to Fable.*

## State of play (July 7, 2026)

- **The flip is built** (`Orbo Astrolabe.dc.html`; previous version kept as `Orbo Astrolabe v1.dc.html`). Double-tap the center → the instrument flips to **the back = you**: birth chart entry (date/time/place/lat/lon, persisted), a natal-ring toggle (natal positions drawn as a faint inner ring on the wheel), geolocation ("use my location" replaces the Richland Center fallback), and an **events list** — add name + datetime; tapping a saved event flips to the front and sends the instrument to that moment.
- **Optional hands** live on the back as toggles: North/South Node (on by default, drawn with a dashed nodal axis; the south end never double-reports aspects), Black Moon Lilith, Chiron. Engine already computed all of them.
- **Big three color-coded** everywhere: ☉ gold · ☽ silver · As sky-blue (readout, wheel, sheet). The As bubble moved out to the outer rim so it rides clear of the zodiac glyphs.
- **Reading sheet is now an eclipse** — a dark disc with a warm corona that rises over the wheel instead of a rectangular sheet.
- **Transport units follow the frame:** horizon lock plays in *minutes*/sec (nuanced timing); free frame plays in *hours*/sec. Same dial, different gear.
- **The field behind the disc** is now a sunrise/sunset gradient of the four Orbo element colors — the dark instrument floats against it.
- **The back is now a rim menu** — twelve engraved slots in zodiacal order from 9 o'clock, panels open in the disc's center, no scrolling: ♈ Natal (city typeahead from bundled `cities.js`, no lat/lon fields) · ♉ Here & Now · ♊ Planets (all ten toggleable) · ♋ dormant (whole-sign is doctrine; VoC/mansions someday) · ♌ dormant (future skins) · ♍ Aspects (orb, which aspects, web) · ♎ People · ♏ Objects · ♐ dormant (lenses) · ♑ Transport (speed, gearing, snap, haptics) · ♒ Events & Horary · ♓ blank. Dev tweaks migrated into ♍/♑ — the instrument is self-contained.
- **Gesture map settled:** tap center = play/pause · **hold center = mark the moment** (save as Person / Event / Horary; "mark + calendar" downloads an .ics) · double-tap the **rim** = flip · double-tap As = horizon lock · double-tap clock = home. Hints live behind an ⓘ instead of footer text.
- **Next:** roster → edge → plate (the composite verb) · lenses/tables · skins (♌) · Moon panel (♋).

## Decisions (July 8, 2026) — the plate language & the next pass

**Audit of the natal ring:** today it is decoration — faint glyphs on a small inner circle, no hit-testing, no aspects, invisible to the engine. Verdict: it becomes **the plate.**

- **Two materials, one law.** Moving sky = *light* (luminous, colored, alive). Natal = *engraved stone* — "glowing black": dark glyphs cut into the plate with a thin rim-light, as if light leaks through the engraving. This is the whole synastry language for free: every person is a plate in the same engraved material (hue-tagged); compositing fuses two engravings into one.
- **Anchored.** The natal never rotates with the frame — it's you, cut into the instrument. In horizon mode it's the one thing that doesn't move.
- **Live, not shown.** Held-body aspect threads reach natal points too, drawn in the engraved tone (thinner/dashed) so sky-to-sky vs sky-to-you never confuse. Snap magnetism catches natal hits — transits to *you* are the point of the app. The reading sheet gets a "to you" section.
- **More radius.** The plate sits *under* the moving bodies at nearly the same radius — engraved beneath the light — not shrunk into the middle. Enabled by thinning the sign-glyph band (it's wider than it needs to be).

**The limb** (adopting the astrolabe term for the graduated outer edge — a.k.a. "the decan ring" in conversation): in horizon lock the tick ring is screen-fixed while the sign tints rotate away, so nothing marks the fixed twelve — even though, whole-sign, the fixed screen-twelfths *are* the houses. Fix: horizon lock gets quiet house articulation (engraved house numbers), and ♌ Appearance offers **decan divisions with ruler glyphs on the limb** — 36 engravings that re-tie the limb to the zodiac.

**The sheet grows a limb; the ⓘ dies.** The eclipse sheet's dark arc stays peeking above the bottom edge permanently — it fills the rectangular dead space and is the pull target. Tap it idle = the how-to-play hints. **Lenses live on its curved edge:** section markers along the arc, same form always, content per context —
- *body held/tapped* (e.g. Mars): *aspects* · *signification* (Mars in Gemini, dispositor, essential dignity, house occupied, houses ruled) · *motion* (speed, Rx, next station/ingress) · *to you* (transits to natal — lights up once the plate is live)
- *nothing selected* (clock): sky summary · what's exact soon · Moon phase
This is "tabs = lenses" from the doc, landed on the instrument's own anatomy instead of a tab bar.

**The clock is the resting state.** The app opens live — 1 sec/sec, real time, the sky simply running. Tap the date = snap to now + re-enter live. Hold the date = date/time picker (precise-entry shortcut, was buried in the back). Any grab breaks live. "You don't load the instrument, you pick it up."

**People get a real door.** "Mark as person" records the instrument's moment at your location — useless for anyone born elsewhere. ♎ People gets the natal form (name + date + time + city typeahead). Prerequisite for roster → edge → plate.

**Renames & slots:** ♑ "Transport" → **Gears** (Saturn: time, machinery; matches the gearbox). **♓ Pisces = Composite Framing** — dissolution of boundaries, two charts fusing into one; the back-side home of the composite verb (front keeps hold-center).

**Build order — smallest first, plate last:**
1. Rename Gears (trivial)
2. Live clock default · tap date = now · hold date = picker
3. Thin the sign-glyph band (reclaim radius for plates)
4. House numbers in horizon lock + decans on the limb (♌ Appearance)
5. People entry form (♎)
6. Sheet limb replaces ⓘ + edge lenses (aspects / signification / motion)
7. **Natal-as-plate** — engraved language, anchoring, threads + snap to natal, "to you" lens
8. ♓ Composite Framing (needs 5 + 7's plate language)

*Built July 8: items 1–6 are in `Orbo Astrolabe.dc.html` (previous state snapshotted as `Orbo Astrolabe v2.dc.html`). Hints now live on the sheet disc itself (fullscreen overlay removed); idle limb is a bare 16px tip that clears the wheel. Remaining: 7 (natal-as-plate) and 8 (♓ composite).*

*Built July 8, later: item 7 — natal-as-plate — is in `Orbo Astrolabe.dc.html` (previous state snapshotted as `Orbo Astrolabe v3.dc.html`).*
- *Engraved language: natal points sit at `rBody − 17` — between the two transit-glyph levels, beneath the light — as dark cuts in faint stone discs with rim-light leaking through below. Ten planets + natal As.*
- *Anchoring decision: the plate is **zodiac-true** (glyphs pinned to their degrees; in horizon lock they ride with the rotating zodiac). Screen-fixing it would break thread/snap geometry — "the wheel stays astrologically truthful" won. In the default sky frame it is fully anchored: the one thing that doesn't move while you scrub.*
- *Live, not shown: held-hand threads reach natal points (dashed, engraved violet `#b9aee0`, single tone regardless of aspect type — sky-to-you never confusable with sky-to-sky); snap magnetism catches natal hits; the gear readout names them ("□ YOUR MOON 0°12′ APPLYING"); tick pulses/haptics fire on natal crossings.*
- *The sheet's limb now carries four lenses: signification · aspects · motion · **to you** (transits from the selected body to natal points; empty states: "quiet — nothing to you in orb" / "engrave your natal on the back to light this up"). Natal panel toggle renamed "the plate — engraved under the sky".*
- *Remaining: 8 (♓ Composite Framing). Open from this pass: tapping a natal engraving directly (plate hit-testing for a natal reading) — deferred.*

**Queued (July 8, from conversation):**
- ♊ Planets & ♏ Objects — replace the rectangular chip grids (they overflow and scroll) with **circular toggles arranged around the back disc**, matching the instrument's anatomy. *(still open)*
- ~~Add **Part of Fortune** and **Vertex** and the four asteroids — **Ceres, Pallas, Juno, Vesta** — as Objects toggles.~~ **DONE (verified July 9).** All six are live: `ephem.js` exports `vertex()` (Ascendant at co-latitude, same RAMC), `partOfFortune()` (Hermetic day/night lot), and the four asteroids as osculating-Kepler bodies (M0 back-solved against a JPL epoch-2460200.5 snapshot — the original M0s were 52–133° off and are now corrected). App side fully wired: `show.{ceres,pallas,juno,vesta,fortune,vertex}` flags, ♏ Objects chips + glyphs, `_active()`, `_posAt`/`_tick` computation (Fortune/Vertex need asc so are computed alongside, not from bare `positions()`), and `_sectionDot`. Spot-checked July 9 2026 against cafeastrology's 2026 calendar: Chiron 0°03′ Tau vs published 0°37′ Tau (Jul 10); Vesta 20°41′ Ari heading to its 27°49′ Ari station (Aug 25); Pallas 18°32′ Ari heading to 22°39′ (Aug 14); Juno 8°20′ Aqu inside its Jun 5–Sep 16 retrograde arc. All within the stated ~0.5–2° drift class.

---

## Plan (July 8, evening) — ♓ Composite Framing: the plate mechanics
*Drafted from a read of `framing.js` + the Composite Framing v2 site. No code yet — a thing to react to.*

### The law the instrument must obey

A composite point is the **short-arc midpoint** of natal × moment. Everything else falls out of that one line:

1. **The 180° arc.** A composite body can never leave **natal ± 90°**. The natal degree is the arc's *center*, not an endpoint. This is the composite's whole physics.
2. **Flip points.** The arc's two ends are the same door: when the transit body reaches exact opposition to the natal, the midpoint jumps 180° — the bead exits one end and re-enters the other.
3. **Half-speed gear.** The composite moves at ½ the transit's velocity. One full traversal of the slot ≈ one return of the transit body to the natal degree (Moon ≈ a month, Sun ≈ a year, cAs = **one day**).
4. **Impossible aspects.** Two arcs share `180° − distance-between-centers` of territory. Arc centers ≥180° apart → zero overlap → that conjunction is *architecturally impossible*. The possibility-space is carved at birth.
5. **Frames vs live.** The site's daily *frame* anchors at natal-ASC-rise (composite angles = natal angles). Between anchors the **cASC sweeps its own 180° once per day** — the film strip between frames. Live view = that sweep made continuous.

### The instrument translation — arcs are *channels cut in the plate*

This is the gift: the composite's math is already astrolabe anatomy. A 180° arc with hard stops isn't a diagram — it's a **curved slot cut in the plate**, like the tympan curves of real brass. The bead physically cannot leave its channel because the channel *is* the law.

- **Third material.** Sky = light. Natal = engraved stone. Composite = **gilt** — light poured into a cut, a molten bead riding a channel. Astrologically honest: the fusion of light and stone.
- **One ring, two meanings.** Each channel is centered on its natal engraving at the same radius (`rBody − 17`) — the natal mark *is* the channel's center notch. No new radius needed at rest.
- **Channel ends = flip stops**, small engraved terminals. On flip, the bead drains out one stop and wells up at the other (a pulse at both ends, never a slide through the natal — that would lie).
- **Zodiac-true**, like the natal plate: channels pin to degrees and ride with the zodiac in horizon lock. (Same anchoring decision as July 8 — thread/snap geometry stays honest.)
- **Grabbing a bead engages its gear** — same promote grammar as the front. Scrub feel inherits the transit body's period; the bead just moves at half rate inside its slot. Rim-gearing and snap magnetism apply unchanged.

### The cAs — the ASC ring bound to its 180

- **cAs = midpoint(natal As, live As).** Its channel is natal As ± 90°, swept once per day — the composite's *hour hand*, the fastest bead on the plate.
- Rendered as a second As bubble riding a **rim arc with two engraved stops** (the only channel on the limb, not the plate — it's an angle, not a body).
- **Houses stay counted from natal As** (whole sign), matching `houseOf(lon, natal.asc)` in the engine — cAs is read as a *point*, not a house re-caster. The site earns this: anchored frames make cASC = natal ASC, so natal-anchored houses are the composite's native frame.
- **Double-tap cAs = go to today's anchor** (the moment your natal ASC degree rises here). The site's daily "frames" become snap targets on the film, not a separate mode. Live is the resting state, exactly like the clock.

### Live by default

No new transport. The composite derives per-frame from the same `jd` — live, play, scrub, magnetism, event-marking all work on the plate the moment it exists. "You don't load the instrument, you pick it up" applies to the plate too: v1 is **You × the moment**, which needs nothing but the natal already engraved on the back.

### Threads & reading

- Bead↔bead threads = the composite's internal aspects, drawn in gilt. Bead↔natal = the "to you" family (engraved violet, dashed) — *transits to your composite* is literally the electional engine's input (`scoreMomentSolo` already scores exactly this).
- **Not** bead↔sky in v1 — three cross-families is noise. While a bead is held, the sky web dims (same rule as held-hand focus today).
- Snap magnetism catches bead exactitudes **and flips** — a flip is the composite's ingress-grade event; it deserves the big haptic.
- Sheet lenses for a held bead: *signification* (composite sign · house from natal As · dispositor) · *aspects* (in-composite) · *motion* (velocity ×½ · **next flip date** · % of slot traversed) · *to you*. The overlap matrix and bonded pairs surface here as readings ("♀ and ♄ share 12° of territory — conjunction nearly impossible"), not as tables.

### Display budget (the real risk)

The wheel already carries ticks, signs, houses, decans, two glyph levels, the natal plate, and the web. Eleven channels + beads + cAs on top is mud. Three focus states:

- **Resting** — channels invisible; beads as faint gilt points among the engraving. The plate whispers.
- **Held** — the held bead's channel lights up end-to-end, flip stops glow, its threads radiate. One channel at a time, ever.
- **Plate view** (deferred) — a promote gesture dims the sky to embers and the composite becomes the rete. Not v1.

### Where it lives

- **♓ panel (back)** = Composite Framing home: engage/disengage the plate, choose the pairing (v1: You × the moment; the panel's empty state points at ♈ if no natal). Later: You × person from ♎ People, person × person — the roster → edge → plate promotion finally lands in its named house.
- Front keeps hold-center = mark; a marked moment while the plate is live should record *composite* state too (the seed of "a composite is a new seed with its own strand").

### Build order (smallest first, again)

1. **Engine lift** — `framing.js` already imports cleanly from `ephem.js`: `midpoint`, `arcFor`, `arcOverlap`, flip detection. Compute live comp per `jd` in `_tick`. No new math.
2. **♓ panel + resting beads** — engage toggle, gilt points at the natal radius.
3. **Held-bead mechanics** — grab/scrub at half-gear, channel lighting, flip stops + flip event pulse.
4. **cAs** — rim arc with stops, daily sweep, double-tap = today's anchor.
5. **Threads + snap + lenses** — to-flip countdown, in-composite aspects, "to you," overlap readings.
6. **Later** — person plates (daily frames per partner), plate stacking, electional lens (`scoreMomentSolo` verbatim: profile chips on the sheet, score as a glow on the clock).

---

## Delegation (July 8) — who builds what

*Tiering rule: anything that decides how the instrument **feels** (gesture, gear, focus states, the plate language) stays with Fable. Anything with a crisp spec, known formulas, and a testable output goes light. Opus takes the middle: real logic, but the design is already decided on this map.*

### Fable (design judgment · interaction feel · canvas integration)
- **♓ steps 2–3** — ♓ panel + resting beads, and **held-bead mechanics** (grab at half-gear, channel lighting, flip stops, flip pulse/haptic). This is the new material's debut; the gilt language and focus states get set here and everything after inherits them.
- **♓ step 4 — cAs** — the rim arc with stops interacts with the As bubble, horizon lock, and the limb; too entangled with existing gesture grammar to hand off.
- **Plate view** (deferred promote gesture) — whenever it happens.
- **♊/♏ circular toggles around the back disc** — a redesign of back-disc anatomy, not a widget swap.

### Opus (well-specified features; design already decided above)
- **♓ step 5 — threads + snap + lenses** — to-flip countdown, in-composite aspects, "to you," overlap readings. Spec and visual language fully written; the aspect/snap engine patterns already exist in v3 to copy.
- **Natal engraving hit-testing** (tap a plate mark → its reading) — mirrors existing body hit-testing with a different target list.
- **♋ Moon panel** (phase, VoC, mansions) — self-contained back panel following the established panel pattern. **VoC + mansions DONE (July 11).**

### Light models (crisp spec, formulaic, testable in isolation)
- **♓ step 1 — engine lift** — port `midpoint` / `arcFor` / flip detection from `framing.js` into the astrolabe's per-`jd` tick. Pure plumbing, verifiable numerically.
- **Part of Fortune + Vertex** — known formulas; `angles()` already exists. Add to `ephem.js` + Objects toggles.
- **Ceres / Pallas / Juno / Vesta** — osculating Kepler elements, same recipe as Chiron in `ephem.js`. Formulaic; validate against published positions.
- **Cities gazetteer expansion**, copy/rename passes, standalone re-bundles, cross-browser regression checks.

*Sequencing note: light-model step 1 (engine lift) and the ephemeris additions can run first and in parallel — they unblock Fable's ♓ 2–4 and Opus's step 5 respectively.*

*Built July 9 — ♓ step 1 (engine lift) is done in `Orbo Astrolabe.dc.html`. `_updateComposite()` runs per jd in `_tick` and keeps three siblings current: `this.comp` (flat bead longitudes incl. `cASC`), `this.compArc` (each bead's 180° channel `{center,start,end}` centered on the natal mark, via `framing.arcFor`), and `this.compFlip` (per-bead boolean, true only on the tick the bead leaps >150° — the transit-hits-natal-opposition flip, bead draining one channel stop and welling at the other). Verified numerically: short-arc midpoint, composite stays inside natal ±90°, flip fires as the transit crosses exact opposition (189.95° → 10.05°). Data layer only — no render/grab yet. Resting-bead draw (step 2) was already present and reads `this.comp` unchanged. Remaining: ♓ 2 (panel + resting beads — mostly present, needs review) through 6.*

*Built July 9 — ♓ step 2 (panel + resting beads) is done. The composite verb finally lives in its named house: **♓ Pisces is now a real rim slot** (`SECTIONS[11]` → `{id:'composite', name:'Composite'}`), the blank twelfth slot filled. Its panel carries the engage toggle (moved out of ♎ People, where it had been parked as a stopgap — People is now purely the roster), the "you × this moment" v1 row, and an empty-state that points tappably at ♈ Natal when no chart is engraved (`goNatal`, gated on `_natalTargets().length`). The ♓ rim slot lights gold when the plate is engaged (`_sectionDot` → `case 'composite'`). Resting beads (gilt points on faint channels at `rBody−17`, `_giltBead`) were already drawing correctly and render as designed — faint at rest, "the plate whispers." Remaining: ♓ 3 (held-bead mechanics) through 6.*

---

## Plan (July 9) — synastry & the composite overlay, translated to the instrument
*From the original Composite Framing overlay screenshot (gold "Me composite" × violet "Person B composite" on one wheel, per-glyph degree labels, natal-anchored houses, AC axis). Written down so the layout survives if Fable runs out of time.*

- **Materials assign the who.** Sky = light. You = engraved stone; your composite = gilt **gold**. Person B = the same two materials **hue-tagged violet** (`#b9aee0` family — the site's purple, made material): B's plate is a violet engraving, B's composite a violet-tinged metal. One law, two hues; the site's legend colors survive as materials, not chrome.
- **The brass limb (built July 9) is the metal recipe.** Directional linear sheen + radial polish across the band + dark stamped cuts with a light-leak edge offset. Beads, channels, and flip stops reuse this recipe verbatim — the bevel was the material study for gilt.
- **Radius budget.** Sky keeps rBody (R−58, two glyph levels). Your plate stays at rN = R−75; **beads ride channels centered on their natal marks at the same radius** — composites never claim a new ring. Person B's plate: ~R−87, and the aspect hub retreats (rAsp R−88 → ~R−102) only while a second plate is engaged. Two plates max on the wheel, ever; more people = swap plates, not stack rings.
- **Degree labels stay off the wheel.** The site prints degrees beside every glyph; the instrument keeps the wheel quiet — degrees live in the gear readout and sheet lenses on hold. Same data, different address.
- **Focus states** (unchanged law): resting = engravings + faint bead points; held = one channel lit end-to-end, sky web dimmed. Never two channels at once.
- **♓ pairings** (the panel's choices): You × moment (v1, live) · You × B (natal × natal is *static* — a gilt engraving, no beads, no film) · B × moment (B's beads run the film) · You ↔ B (pure synastry: two engravings, natal↔natal threads on demand).
- **cAs / daily frames are per-person:** B's frames anchor when *B's* natal As degree rises here; each moving pairing gets its own cAs rim arc + double-tap = today's anchor.
- **Legend → lens.** The site's bottom legend becomes a material key on the sheet's ♓ lens, not floating chrome.
- **Pickup order** if Fable is out: ♓ panel + resting beads → held-bead mechanics (half-gear, channel lighting, flip stops + pulse) → cAs arc → threads/snap/lenses (Opus spec, July 8) → B plate + radius retreat → synastry thread family.

---

## Delegation pass (July 9) — the remaining work, re-sorted

*A fresh sort of everything still open, across Fable / Opus / Sonnet. Tiering rule unchanged: whatever decides how the instrument **feels** (new material, gesture, focus states) → Fable; well-specified logic where the design is already drawn on this map → Opus; crisp, formulaic, numerically-testable work → Sonnet. The binding constraint this pass is **Fable's budget is nearly spent** — so Fable is rationed to the one thing only it can set, and every other feel-adjacent item is either absorbed by Opus against the language Fable sets, or parked for a future Fable budget.*

### Fable — spend the last of the budget here, nowhere else
- **♓ 3 — held-bead mechanics.** The debut of the **gilt** material and the composite focus states; ♓ 4/5/6 all inherit whatever it sets. This is the single highest-leverage use of Fable's remaining ~12% — do not let it fall to another tier, and do not spend Fable budget on anything below. Fully briefed in `Fable Brief — Composite Held-Bead (Pisces 3).md`; all plumbing is wired, so it's pure look/feel.
- *Parked for a future Fable budget (do NOT start now):* the **radial chip ring** (♊/♏ toggles around the back disc — back-disc anatomy redesign, optional refinement) · **plate view** (the deferred promote gesture) · the **violet material study** for Person B in ♓ 6. Each is feel work that would ideally be Fable's; none is worth pre-empting ♓ 3.

### Opus (me) — logic where the design is already decided
- **♓ 4 — cAs rim arc** (rim arc + two engraved stops, daily sweep, double-tap = today's anchor). Geometry, but entangled with the As-bubble / horizon-lock / limb gesture grammar — too woven into existing interaction to hand off. Already reassigned here.
- **#9 — natal-engraving reading** (tap a plate mark → its reading). In progress; finish it. Mirrors existing body hit-testing against a new target list.
- **♓ 5 lens *content*** — the readings' wording and thresholds ("♀ and ♄ share 12° — conjunction nearly impossible", to-flip countdown copy, overlap/bonded-pair phrasing). Judgment about what the instrument *says*; pairs with Sonnet's thread/snap plumbing below.
- **♓ 6 plate-swap + radius-retreat logic** (two-plates-max rule, aspect-hub retreat while B is engaged, per-person cAs anchoring) — the mechanics behind Fable's parked violet material study.

### Sonnet — crisp, formulaic, testable in isolation
- **♓ 5 threads + snap plumbing** — bead↔bead and bead↔natal thread geometry + snap-magnetism on beads/flips, copied from the existing transit-hand aspect/snap engine. Patterns already exist in v3 to mirror; Opus supplies the lens copy on top.
- **♋ Moon polish** — real **VoC** (last-aspect-before-ingress scan) and the **28 mansions** (fixed 12°51′26″ divisions). **DONE (July 11) — see S4 handoff.** Self-contained, numerically verifiable against published tables; the panel itself is already built.
- **Grunt & regression** — cities gazetteer expansion, copy/rename passes, standalone re-bundles (`*-standalone-src` → `* Standalone.html`), cross-browser regression checks.

### Sequencing
1. **Now, in parallel:** Fable → ♓ 3 · Opus → #9 + ♓ 4 · Sonnet → ♋ Moon polish (fully independent).
2. **After ♓ 3 sets the gilt/focus language:** Sonnet → ♓ 5 threads+snap plumbing, then Opus → ♓ 5 lens content on top.
3. **Last:** ♓ 6 — Opus plate-swap/radius logic, with Fable's violet study whenever a Fable budget reopens.

### Addendum — items the first sort missed (July 9)

*Six things surfaced after the pass. Sorted by the same rule; two are genuinely Fable-tier feel decisions, so they get rationed against the ♓ 3 budget rather than absorbed.*

**Fable — the two that set feel (queue directly behind ♓ 3, ahead of the parked list):**
- **The Sun/Moon eclipse metaphor** — frame the whole instrument: **astrolabe = Sun panel** (information), **pull-up info panel = Moon panel** (meaning), and the sheet rising over the wheel should read as an **eclipse** (Sun occluded by Moon) — light retreating as meaning slides over data. This is the top-level metaphor everything else hangs on; only Fable should set the transition's look. If budget truly won't stretch, Opus can implement against a one-paragraph Fable note, but the *look* of the eclipse is Fable's call.
- **Natal-engraving inversion** — white lettering with an inner shadow (**debossed/intaglio** look) instead of the current treatment. Material/light decision on the engraved-stone identity; pairs naturally with the ♓ 3 material session, so fold it into that sitting rather than spending a separate budget.

**Opus (me) — logic + placement where the language is settled:**
- **DSC as a fourth angle.** Add **Descendant** opposite the Asc, alongside MC/IC — completes the four angles. Pure geometry (DSC = Asc + 180°), but it touches the As-bubble/horizon-lock grammar I already own, so it stays here. Small.
- **Transits feature — surfacing + placement.** Design where upcoming transits-to-natal live and how they read. Proposed home: the **Moon/meaning panel** as a dedicated lens (consistent with the eclipse metaphor — transits are *meaning over time*). Surface as a **list/timeline of exact hits, sortable by date, filterable per-natal-body**. Opus owns the placement decision, panel layout, and copy; **Sonnet owns the ephemeris math** (see below).
- **Date/time header color audit.** Decide the intended source — tied to **Sun**, to **Asc**, or **always fixed** — and make it intentional rather than incidental. Judgment call about what the header *means*; I'll pick a source and document it, then it's a trivial wire-up.

**Sonnet — formulaic, testable:**
- **Transit ephemeris engine** — compute exact transit-to-natal hit times (aspect-partile crossings) for the list/timeline Opus lays out. Self-contained, numerically verifiable against an ephemeris; mirrors the existing aspect-scan math.
- **Ring-layering pass** — keep **transit planets on the OUTER ring** (so conjunctions get depth-of-field) and the **INNER ring clean** for the second (composite/natal) chart; apply the **Vertex layering treatment** (which already works well) uniformly to all other planets & objects. Mechanical once the Vertex pattern is the reference — copy it across.

### Addendum 2 — synastry + composite theory decisions (July 10, Fable pass)

*From the user's theory review + the midpoint-composite reference doc (`uploads/Midpoint Composite Charts in Astrology.pdf`).*

**Decided:**
- **Composite Framing toggle REPLACES the natal-chart toggle** — beads occupy the inner track in the natal plate's place, one occupant at a time. Same seat, same legibility standard, different material (stone vs gilt).
- **♓ 3 redirect:** resting lived view is the product — gilt *glyphs* with identity (not anonymous dots), cAs as a lived gilded half-arc on the rim sweeping in real time (±90° boundary present but quiet). Held/channel state kept but demoted; flip = quiet pulse, not the show. Both natal engraving and beads need a legibility pass.
- **Theory frame:** the current composite is the chart of the third entity **you-and-now** (you + sky midpoints). A classic **A+B composite** (two people) is a *fixed* chart — a different animal; don't let both wear identical gilt without a deliberate distinction.

**New to-dos:**
- **Synastry (Person B)** — B's chart placement: second engraved plate sharing the inner region, shifted stone tone (violet study), aspect-hub radius retreat. B never goes outside the transit ring (sky = the world). Feel → Fable (parked); mechanics → Opus (♓ 6).
- **Inter-chart aspects** — synastry thread family: threads crossing plate-to-plate (A↔B), never touching the sky; same thread grammar, distinct family styling. Plumbing → Sonnet (mirrors ♓ 5 threads); reading copy → Opus.
- **Transits-to-composite** — Sonnet's transit-ephemeris engine should accept the composite (and later A+B composite) as a target chart, not just the natal. Plan for it now; retrofit is costly.

### Addendum 3 — status + the two-seat law (July 10, Fable)

**Done (♓ 3 + ring layering):** intaglio debossed natal engraving · composite replaces natal on the plate when toggled · beads are gilt glyphs with identity · channels/flip stops light on hold only · flip = quiet welling pulse + big haptic · beads win the inner band · cAs promoted to gilt rim badge (♓ 4's seat, visual language set) · conjunctions stack along the rim Vertex-style (depth-of-field, 6px step) — live bodies never sit on the plate · gilt header readout while a bead is held.

**Seating model (LOCKED, July 10):**
- Two mes: **natal-me** (stone) and **composite-me** (gilt) — both can hold the plate.
- **"Them" = a person OR an event** (the events tab feeds the same seat). Them always takes the **rete (outer)** seat in their material; **me defaults to the plate (inner)**.
- **Synastry is FROZEN, always** — no transport sweep while a person/event acts; the seat flip is the only motion.
- Solo mode: rete lifts off (no sky glyphs); zodiac/horizon/transport remain; composite default opens solo, sky joins on request.
- Readings: Sky × Me (either me) · Me, alone · Me × Them (person/event, frozen, flippable).
- **Two seat info panels** (per reference screenshot, `uploads/Screenshot 2026-07-08 at 6.42.18 PM.png`): corner cards naming each seat's occupant — left = plate (name, date/time, place, zodiac), right = rete ("current transits" / person / event + its moment). They ARE the seating chart's readout; tapping one could open the seat picker.
- Crowding fix (uniform plate grammar): recessed plate band ~30px in, engraved glyphs, mirrored inward degree ticks, depth separates seats, materials name the who.

**Still queued:** eclipse metaphor (Sun/Moon panel frame) · ♓ 5 threads/snap + lens copy · ♓ 6 B-plate + radius retreat · DSC angle · transits feature + ephemeris engine · date/time header audit · ♋ Moon polish (VoC, mansions) · synastry threads · transits-to-composite.

*Sequencing note:* DSC and the header audit are quick Opus wins, do them alongside #9. The eclipse metaphor is Fable's next sitting after ♓ 3 and should land before the Moon-panel transit lens is styled. Ring-layering (Sonnet) is independent — can run anytime.

---

## Cleanup & redundancy pass (July 10, Fable audit) — no code touched

*A code-verified audit of `Orbo Astrolabe.dc.html` against the four reported issues, plus redundancies found along the way. TODO + delegation below; nothing changed yet.*

### Findings (verified in source)

**A. ♌ Appearance — the silver framing never reached the pull-up.** The six limb chips (off / engraved / brass / brass·faces / silver / silver·faces) live under the "decan rim — the limb" heading and `skin.limb` is read *only* by the wheel's rim draw (`_draw`, ~line 1848). The sheet's corona is hard-coded warm brass in the template (line 451). So the "new look for the lunar pull-up" was mis-landed as two extra wheel-rim materials — the astrolabe's brassery and the Moon-sheet's framing are conflated in one chip row. Bonus redundancy: `_setLimb` also writes the legacy `skin.decans` boolean, and `_sectionDot('skin')` still reads it — one fact stored twice.

**B. Phase-true Moon exists twice, but not in the BIG THREE.** The wheel Moon draws a true terminator from the Sun's position (~line 2294); the ♋ panel has its own 72px phase canvas. The header readout (`skyRef`) prints `☽` as a text glyph via innerHTML in three code paths (normal sky, solo-composite gilt, held-Moon). No shared drawing routine — three independent moon renderings once the header joins.

**C. Seat cards are always-on and half-redundant with the clock.** The plate/rete cards render unconditionally (template lines 45–56). In the default seating (natal plate + live sky) the rete card reads "The sky · current transits · live" — restating the clock directly above it — while the date (`civilRef`) sits outside both boxes. The cards earn their space only when seating is *non-default*.

**D. MC/IC are the largest lettering on the wheel; DSC missing.** MC/IC go through the generic body loop: `fillText(GLYPH[o.n])` in the symbol serif at `base = 23 − 1.2·log10(PERIODS)` — their period (0.99727) makes "MC"/"IC" render at ~23px, bigger than any planet glyph. Vertex "Vx" shares the defect. The As badge (bold 9.5–11px sans in a ring) is the correct scale reference. DSC exists nowhere (no show flag, no `_posAt`, no chip).

**E. Unprompted redundancies & overlooked basics**
1. **Three doors to one seat**: ♈ `showNatal` toggle ("the plate — engraved under the sky"), ♓ engage toggle, and the plate seat picker all govern the plate occupant. `showNatal:false` + `composite:true` interaction unaudited — likely contradictory.
2. **Stale seated occupant**: `_setRete` persists a *copy* of the person/event object; deleting them from ♎/♒ leaves the ghost seated with no way to notice.
3. **DONE (July 11)** — ♋ VoC real data landed, no longer "coming soon."
4. Standalone bundles (`Orbo Astrolabe Standalone.html`, v3) predate the plate/composite/seat work — stale exports.
5. Snapshot hygiene is fine (v1–v4 intentional), no action.

### TODO + delegation (token-budget sorted)

**Fable — one sitting, feel only (budget rationed):**
- **F1. The sheet in the Moon's metal.** Decide + set the look: the pull-up *is* the Moon panel (eclipse metaphor — this is that sitting's first half), so its corona/rim goes silver — the cool `MP` silver ramp from the limb draw is the ready-made palette. Decide whether it's *always* silver (no control at all — preferred; kills the mis-landed toggle cleanly) or paired brass/silver with the wheel. Output: the styled sheet + a one-line law for A's re-homing.

**Opus — structure & law (design already mapped):**
- **O1. ♌ re-home (fixes A).** Split the chip row into two honest controls: *decan faces* (off/engraved) and *rim metal* (none/brass/silver); retire `skin.decans` (migrate on load); sheet framing follows F1's law — no sheet chip unless F1 says "paired".
- **O2. Seat-card visibility law (fixes C).** **USER-DECIDED (July 10):** cards hidden in default seating (natal engraved, live sky, composite off); shown whenever composite is on OR rete ≠ sky. **When the cards appear, the date/civil line MIGRATES INTO the header cards and disappears from under the big three** — the moment's date travels to whichever card names the moment being read (rete card for a frozen person/event, plate card for composite-me's lived now; live sky card carries today's date). One clock, one address, never two. Entry point while hidden: still Opus's call (small ⇅ glyph right of the clock proposed). Clock tap/hold gestures (play, date picker) stay on the big-three block regardless.
- **O3. Angle-letterform treatment (fixes D, sets the type).** MC/IC/DSC/Vx leave the symbol-serif path: bold ~8.5–9px sans (As-badge family, no ring, quieter alpha). DSC grammar: opposite the As bubble, same badge language at reduced weight. Opus owns angles per the July 9 sort.
- **O4. One seat, one law (fixes E1).** Consolidate: seat picker is canonical; ♈ `showNatal` becomes an alias or dies; define `showNatal × composite` truth table.

**Sonnet — formulaic, testable:**
- **S1. `_moonFace(ctx, x, y, r, sunLon, moonLon, opts)` helper** — extract from the wheel draw; reuse in wheel + ♋ panel + new header mini-canvas (fixes B; unifies three renderings into one). Header: persistent 16px canvas element between the readout spans (innerHTML rewrite must not orphan it), redrawn per tick; also the held-Moon and gilt-composite paths.
- **S2. DSC wiring** (after O3 sets treatment): `show.dsc`, `pos.DSC = norm(asc+180)` in `_posAt`/`_tick`, ♏ chip, PERIODS/GLYPH/LABEL/NO_RX entries.
- **S3. Stale-seat guard (fixes E2)**: on delete from ♎/♒, if the seated rete matches (jd+name), reset rete to 'sky'.
- **S4.** **DONE (July 11).** ♋ VoC last-aspect-before-ingress scan + mansions.
- **S5.** Re-bundle standalones after this pass lands + regression sweep.

**Sequencing:** F1 first (one sitting — its law gates O1's final shape) → O1–O4 in one Opus block (all header/back-panel adjacent) → S1–S3 after (S1 needs no gate and can run parallel to Opus; S2 waits on O3). S4/S5 anytime after.

---

## The Derivation Law (July 10) — the whole backlog re-read through it

*Named in conversation: historically the astrolabe answered one question — **where is everything right now**. Natal charts, transits-to-natal, synastry, composites were paperwork done* with *it, not* on *it. We collapse "with" into "on": the seats are the paper brought onto the brass. From that, one test applied to every remaining item:*

> **The instrument shows the moment. Everything derived must (a) earn its appearance by being actively in use, and (b) read as visually subordinate to the sky it derives from. Anything that restates the moment twice, or dresses a derivation as a primary body, is the redundancy.**

*Derivation depth, for reference: 0 = the sky-state (positions, angles, phase — the instrument itself) · 1 = one chart laid on it (natal, a person, an event) · 2 = readings across layers (transits-to-natal, synastry threads) · 3 = new entities minted from layers (composites, marked moments). Higher depth = quieter material, later appearance, more deliberate summoning.*

### Every open item, re-audited against the law

**Pass unchanged (already obey it):**
- **Cleanup pass F1/O1–O4/S1–S5** — the law is what produced them; O2 (seat cards hidden at rest) and O3 (angles as engravings, not occupants) are its purest expressions.
- **♓ 5 threads + snap + lenses** — already designed subordinate: gilt threads only while a bead is held, sky web dims, one channel ever. Depth-3 content summoned by grip. Correct.
- **♋ Moon VoC + mansions (S4)** — depth-0/1 readings living in a panel, appearing only when asked. Correct.
- **Ring-layering pass** (transit planets outer, Vertex depth-of-field everywhere) — literally enforces "sky owns its ring, derivations never dress as bodies." Correct; unblocked, run anytime.
- **Stale-seat guard (S3), standalone re-bundles (S5), cities expansion** — hygiene, law-neutral.

**Pass with a sharpened spec:**
- **Eclipse metaphor (Fable's next sitting)** — the law *strengthens* it: astrolabe = the moment (depth 0), sheet = the paperwork (depth 1+). The eclipse transition is the law made visible — meaning sliding over measurement. Sharpened: the sheet must never show depth-2/3 content when nothing is held/seated that summons it; its resting lens is depth-0 only (sky summary, what's exact soon, Moon phase). Fold F1 (silver sheet) into this sitting — Moon's metal for the meaning layer is the same statement.
- **Transits feature (Moon-panel lens + Sonnet ephemeris engine)** — a depth-2 reading, so: it lives in the sheet (paper), never on the wheel; it appears only when a natal is engraved (its source layer exists); its rows point back at the instrument (tap a hit → transport eases to that jd) rather than duplicating chart data in prose. The engine (Sonnet) is unchanged; the placement spec now has a reason instead of a preference.
- **Date/time header color audit (Opus)** — the law decides it: the header is the depth-0 readout, the instrument reporting its own state. So its color derives from the sky-state (the existing element-color language already used for ☉/☽/As), never from a seat, a held derivation, or a fixed brand tone. Exception already correct in code: solo-composite mode golds the readout — acceptable *because* the whole instrument has been re-seated to a depth-3 entity; the header is truthfully reporting whose moment it shows. Document that as the rule: **header color = whichever chart owns the wheel right now.** **DONE (July 11, Sonnet audit) — no code change needed.** `dateInRete`/`dateInPlate` seating already route the readout through `seatReteCol`/`seatPlateCol`, which key off `s.composite` (gold) vs natal (`#beb8e2`) — the rule was already implemented, including the solo-composite gold exception.
- **#9 natal-engraving reading** (in progress) — depth-1 object opening depth-2 content (transits to it). Fine, but the law adds: the reading opens in the *sheet*, the engraving itself never brightens to sky-material on tap. (Current implementation already does this — verify, don't rebuild.)

**Re-scoped by the law:**
- **♓ 6 — B-plate + synastry + radius retreat** — the biggest beneficiary. The law hardens the July 10 seating addendum into specs: (a) B is depth-1 *paper* — matte stone, violet-tagged, **frozen always** (a person is a fixed chart; only the sky flows); (b) synastry threads are depth-2 — they exist only while the comparison seating is active, never at rest; (c) an A+B composite is depth-3 — a *minted entity*, so it must be deliberately created (a verb, not a toggle side-effect), and must not wear identical gilt to composite-me without a distinction (the map already flagged this — the law explains why: two different depth-3 entities, two identities); (d) the radius retreat (aspect hub pulls in while B is seated) is the "earn its appearance" clause in geometry — space is granted only while the derivation is in use, and returns when B leaves.
- **Transits-to-composite (Sonnet engine target)** — depth-2 reading *of* a depth-3 entity: legitimate, but only reachable while the composite holds the plate. Build the engine chart-agnostic now (as planned); gate the *surface* by seating. **DONE (July 11, Sonnet audit) — no code change needed.** `_txBuild()` already branches on `T.compositeTarget(nat)` vs. a natal-target snapshot, both fed through the same generic `targetFn`/`targetBodies` shape into `T.nextExactHits`; the transits.js front door is already chart-agnostic and ready to take a B/AB target for ♓6 with no retrofit.
- **Two-seat info panels** — subsumed by O2 and the law: they are the *paperwork manifest*, listed only when paper is on the brass. (Was "per reference screenshot, always-on corner cards" — the always-on part is repealed.)
- **Radial chip ring (♊/♏ around the back disc, parked Fable)** — law-audit verdict: the back is *setup*, not the instrument; chips are depth-neutral controls. Cosmetic anatomy-matching adds no derivation clarity. **Demoted to last** — do it only if a Fable budget reopens with nothing above it. (Was: parked. Now: parked with a reason.)
- **Plate view (deferred promote gesture)** — the law legitimizes it as the one sanctioned *inversion*: deliberately re-seating a derivation as the primary (dim the sky to embers, composite becomes the rete). Keep deferred, but note it must be an explicit promote gesture with an obvious way back — never a mode you drift into. Solo-composite's golden header is its precedent.
- **Event capture / calendar export (open item #5, original doc)** — minting a moment is depth-3 creation from depth-0 state: the gesture (hold center) is correct; the .ics export is the paperwork leaving the instrument. No change, but the law confirms hold-center should capture *the seating too* (whose moment it was) — already noted in ♓ plans, now a requirement.
- **Roster entry (open item #1)** — People are depth-1 paper stored on the back. The front-side promotion (roster → seat) is the only door they need; a front-side roster UI would be paper claiming instrument space at rest. Verdict: the seat picker (O2's entry point) *is* the roster's front door — no separate front-side roster ever.

**Flagged as latent law-breaks (new, small):**
- **L1. ~~Solo-mode readout truth-check~~ RESOLVED by the O2 user decision (July 10)** — the date-migration rule dissolves the ambiguity: the big-three block is always the depth-0/owned-chart readout, and *the date lives wherever the reading's moment is named* (under the big three at rest; in the seat cards during comparison). No separate Opus decision needed; implement as part of O2.
- **L2. Gear readout during bead-hold already obeys** ("COMPOSITE ASCENDANT · 1 SWEEP = …" in gilt) — noted as the pattern L1 should follow.
- **L3. ♐ Lenses slot (dormant)** — the sheet's lenses made a dedicated back-panel for them redundant before it was ever built. Verdict: retire the reservation; ♐ becomes free real estate (transits feature is the natural tenant — Sagittarius, the far-seeing). Rename when the transits lens lands.

### Delegation deltas (only what changed)
- **Fable:** eclipse sitting now *includes* F1 (silver sheet) — one sitting, not two. Radial chip ring demoted to dead-last. Nothing else new.
- **Opus:** + L1 decision · + header-color rule documentation (absorbs the old "header audit" item) · ♓ 6 spec hardened as above (mechanics unchanged, reasons attached) · seat-picker-as-roster-door folded into O2.
- **Sonnet:** unchanged, plus: build transit engine chart-agnostic from day one (natal / composite / A+B as interchangeable targets) — explicitly *not* a retrofit.

### Handoff (July 10, third pass) — minor aspects, individually toggleable, everywhere aspects live

Source: user's uploaded "Guide to Astrological Aspects in Natal and Transit Charts" (traditional +
modern readings for all 5 majors plus 9 minors). Per explicit user direction, NOT a single "minors"
toggle — each of the 9 new aspects (semisextile 30°, semisquare 45°, septile 51.43°, quintile 72°,
biseptile 102.86°, sesquiquadrate 135°, biquintile 144°, quincunx 150°, triseptile 154.29°) is its own
chip in `this.ASPECTS`/`this.ASYM`, keyed by angle exactly like the 5 majors already were — the
`aspOn` state map was already angle-keyed and per-chip, so individual toggling needed no new
plumbing, just more entries. Majors default on, minors default off (`ASP_DEFAULTS`) so existing users
see no change until they opt in; ♍ Aspects panel chip row now wraps (matches the ♊/♏ circular-chip
style) instead of the old 5-across strip. Minors get a tighter fraction of the single global orb slider
via `ORB_SCALE` (0.5 for the aversion family semisextile/quincunx, 0.45 for the minor-Mars family
semisquare/sesquiquadrate, 0.4 for the 5th-harmonic quintile/biquintile, 0.35 for the 7th-harmonic
septile family) through a new `_orbFor(ang)` helper — every orb comparison site (aspect status
readout, snap magnetism, transits-to-natal, sky hits, per-body aspect list, to-you list, the wheel's
aspect web, held-hand-to-plate threads) now calls it instead of the flat slider value. Colors/glyphs
group by family (adjustment minors muted amber, minor-Mars minors dusty red, quintile family violet,
septile family teal) so the web stays legible once several are on at once.

Out of scope, left alone: `framing.js`'s own `ASPECTS` (majors only) — it feeds the electional scorer's
`Q` weight table, which has no entries for the new angles; touching it would silently NaN the
scoreDay/scoreMomentSolo scores. Interpretive copy from the doc (traditional vs. modern, internal vs.
external transit framing) is NOT wired in yet — that's lens-copy judgment, Opus's lane per the existing
split, and was pitched back to the user before this pass; still open if wanted.

### Handoff (July 10, second pass) — transit ephemeris engine done

**Done, new file `transits.js`:** `scanTransitHits({target, jdStart, jdEnd, ...})` finds every exact
(partile) transit-aspect crossing between a moving body set and a target chart over a jd range,
by sampling a signed function per (transitBody,targetBody,aspect) trio for sign changes and
bisecting to the exact instant (mirrors `findAscAnchor`'s method in `ephem.js`). Built chart-agnostic
per the brief: `target` is just `jd => {bodyName: lon}` (or a constant object) — three builders ship
for the current use cases: `natalTarget(natal)` (constant), `compositeTarget(natal)` (the live
You×moment midpoint, recomputed per jd — no anchor/frame needed, matches the "live by default" law),
and `compositeABTarget(natalA, natalB)` (a fixed two-person composite). `nextExactHits(opts, jdFrom, count)`
wraps the scanner with an expanding search window for "next N hits" use. Aspect defs/glyphs are
imported from `framing.js` (no duplicate source of truth).

Caught and fixed one real bug via the numerical check: unsigned separation only *touches* 0°/180°
and turns around rather than crossing through, so conjunction/opposition were silently never firing
until the detector switched to a signed relative-longitude test for just those two angles. Verified
against the sample natal in the file header comment — solar return exact to the calendar date,
Moon-to-natal-Sun recurring every ~27.3 days, composite rate exactly half the transiting rate.

Wired into `Orbo Astrolabe.dc.html` the same way `ephem.js`/`framing.js` are: `window.__ORBO_TRANSITS`
at helmet-load time, `this.transits` after mount. Engine only — no UI. Per the July 9 sort, the
Moon-panel lens layout/copy (♐ tenancy) is Opus's to build on top; ♋ VoC + mansions is still queued.

### Handoff (July 10) — Sonnet's block is done

**Done, in `Orbo Astrolabe.dc.html`:**
- **S1 — moon-face helper.** Extracted `_moonFace(ctx,x,y,r,sunLon,moonLon,opts)`; the wheel's Moon glyph, the ♋ panel canvas, and a new persistent 16px header disc (sits beside the big-three readout, outside the skyRef innerHTML rewrites so the three header text-branches never orphan it) all paint from the one routine now. Phase math verified equivalent to both prior implementations (`k=(1-cos(el))/2 ⟺ |1-2k|=cos(el)`).
- **S2 — DSC wiring.** Descendant promoted from a decorative always-on line to a real toggle: `PERIODS/GLYPH/LABEL/NO_RX` entries, `show.dsc`, `_active()` push, `pos.DSC` computed in both `_posAt`/`_tick`, ♏ Objects chip. Tap-to-read, aspects, and snap all inherit for free through the same generic path MC/IC already used — no special-casing needed. Quiet unlit backing line still draws when the toggle is off.
- **S3 — stale-seat guard.** Two halves: deleting a person/event from ♎/♒ now checks it against the seated rete by (jd, name) — `_setRete` freezes a copy, not a reference — and releases the seat to `'sky'` if it matches. Clearing the natal date (natal's sole presence gate) while composite is engaged now force-disengages composite via the same fallback `_toggleComposite`'s off-switch uses, instead of leaving the plate seated on a chart that no longer exists.

**Pass-off:** Sonnet's assigned block (S1–S3) is fully delivered and unblocks nothing further on its own — next up per the sequencing below is Fable's eclipse-metaphor sitting (item 1), then Opus's cleanup block (item 2). No open Sonnet items remain from this pass; S4 (♋ VoC + mansions) and the transit ephemeris engine are still queued for whenever Sonnet is picked up again.

### Handoff (July 11) — S4 (♋ VoC + mansions) and ♓5 threads+snap plumbing, both done

**S4, in `Orbo Astrolabe.dc.html`:** real void-of-course replaces the "coming soon" placeholder.
`_moonIngressJd()` finds the Moon's next sign boundary (forward scan + bisect, mirrors the
existing ingress logic). `_vocData()` scans `transits.js` for the Moon's exact Ptolemaic-major
hits against the other six classical bodies (Sun..Saturn) up to that boundary — no hits before
ingress means the Moon is void now; the last hit found names when the void begins. The 28
manazil al-qamar (lunar mansions, fixed 12°51'26" slices from 0° Aries) are added as a static
gazetteer (`this.MOON_MANSIONS`) with `_mansionOf(lon)`; both read out as new rows in the ♋ panel.

**The lunar-transits lens (unlocked by S4, per the July 10 addendum):** a short-window
(6-day), Moon-only, natal-only scan (`_moonTransitsData()`) lives directly in the ♋ Moon panel
beneath the VoC/mansion rows — "the fast hand," sharing math with VoC (both call `transits.js`
with `transitBodies:['Moon']`) but not the ♐ engine itself (deliberately not a duplicate; ♐
stays the slow far-seeing arc excluding the Moon by default, ♋ is the fast lunar one). Rows
reuse the ♐ lens's gloss/family vocabulary (`_txLore()`); tapping one eases the transport there,
closing the back panel. Placement/copy is provisional (Sonnet built it end-to-end since Opus's
copy pass hadn't run yet) — flag for an Opus look if the wording needs a pass.

**♓5, same file:** bead threads + snap-magnetism, mirroring the existing held-transit-hand
patterns. `_applyBeadMagnet(raw, beadKey)` sits beside `_applyMagnet` and is now called from
`_move` whenever a bead is held — it catches three families: other beads (in-composite
exactitudes), natal points (the "to you" family), and the bead's own channel ends (the flip
boundary, so a flip lands instead of drifting past). Thread drawing added to `_draw`'s composite
block, held-only: bead↔bead in gilt, bead↔natal in the engraved violet dashed style, both exactly
one radius shallower than the held-hand version — never bead↔sky, per the map's three-family
noise rule. Lens copy (in-composite aspect readings, to-flip countdown, overlap phrasing) is
**DONE (July 11, Opus)** — `_beadStatus(beadKey)` beside `_aspectStatus`, read out in the header's
gear line while a bead is held (mirrors the held-hand telemetry). It reports, in one line and null-
falling-back to the sweep period: the tightest in-composite aspect (`[sym] ☽ 1°02′ APPLYING` for
bead↔bead gilt, `[sym] YOUR MOON …` for bead↔natal violet), an **overlap** phrasing that replaces the
degrees when a tight conjunction lands (`OVER YOUR SUN` on a natal point, `☌ ☽ — STACKED` on another
bead), and a **to-flip countdown** (`FLIP IN 3 days` / `AT FLIP`) as the bead nears its channel end
(transit opposing natal). Bead↔sky is never read, per the three-family noise rule.

**Remaining from this pass:** a look at whether the lunar-transits lens
placement/wording wants Opus's pass per the July 10 sort.

### Master sequence (everything open, one list)
0. ~~**Fable** — silver sheet~~ **DONE (July 10, the Fable sitting).** The pull-up is now in the Moon's metal: cool silver corona, rim, and highland tints replace the warm brass framing; row separators cooled to match. **The law it sets: the sheet is ALWAYS silver — no control, ever.** The mis-landed toggle question is dead; O1's scope is now purely wheel-side (decan faces × rim metal), no sheet chip. Gilt accents *inside* the sheet (active lens, applying-aspect amber) deliberately stay warm — the Sun's light at the eclipse's edge, meaning lit by data. The eclipse *transition* (how the rise reads as occlusion) remains open for a future Fable sitting; the material statement is set and everything after can inherit it.
1. ~~**Fable** — eclipse metaphor + silver sheet~~ **DONE (July 10, the eclipse sitting — snapshot kept as `Orbo Astrolabe v5.dc.html`).** The occlusion is now literal, three layers: (a) **the light retreats** — a canvas shadow sweeps up the wheel from the lower limb (`this._eclipse`, eased per tick, deepest nearest the Moon-disc) plus a DOM veil dimming the sunset field & stars; the header readout (depth-0) stays lit above — measurement keeps reporting while meaning covers it. (b) **First contact** — a one-shot warm gilt flash at the sheet's upper limb as it rises (the Sun's light flaring at the Moon's edge), settling into (c) **the totality corona** — the silver rim glow blazes brighter while the sheet is up. Law confirmed: warm flash is the only gold on the sheet's rim, ever; the settled corona is always cool silver. **Second half — the resting depth-0 lens landed:** tapping the idle sheet now opens "the sky right now" (Moon phase disc via `_moonFace` + phase name/% lit/sign · the big three in their colors · "tightening now" = top-5 applying pairs across the active sky, `_skyHits()`) instead of hints; hints remain the first-run default until dismissed and live behind a "how to play" link on the summary. The sheet finally is the Moon panel: meaning at every depth, summoned or not, never showing depth-2/3 without a summons. *Verified against the Derivation Law — sharpened spec obeyed.*
2. **Opus** — cleanup block O1–O4 + L1 + header rule doc + finish #9.
3. ~~**Sonnet** — S1 moon-face helper (parallel with 2) · S2 DSC (after O3) · S3 stale-seat guard.~~ **DONE (July 10) — see Handoff note above.**
4. **Sonnet** — transit ephemeris engine (chart-agnostic) · ♋ VoC + mansions. ~~**Opus** — transits lens layout + copy in the sheet (♐ tenancy, after Fable's sitting).~~ **DONE (July 11, snapshot `Orbo Astrolabe v6.dc.html`).** The transits feature landed on both anatomies the map called for: the dormant ♐ slot is now a real rim panel (`SECTIONS[8]` → `{id:'transits', name:'Transits'}` — Sagittarius, the far-seeing; the reservation retired per L3) whose door explains the lens and opens the pull-up, and the reading itself lives in the **sheet** as a new depth-2 mode (`sheet:'transits'`, `_sheetDataTransits`), obeying the Derivation Law: it lives on the paper, never the wheel, and only exists once a natal is engraved (empty state points at ♈).
   - *Engine use:* `transits.js` verbatim — `nextExactHits({target, targetBodies, aspects, transitBodies}, anchor, 40)`. Target is chart-agnostic: `natalTarget` (You, incl. As) by default; `compositeTarget` offered when composite is engaged (♐ panel target chips, shown only then). Aspects honor the live `aspOn` set (majors + any minors the user turned on), glyphs/orbs from the existing maps.
   - *Anti-flood:* the Moon is **excluded by default** as a transiting body — it aspects everything every few days and buried the slow, life-timing transits. A single "+ include the moon" toggle brings it back. (`txMoon` state; folded into the cache key + transitBodies filter.)
   - *Layout:* title → subtitle → moon toggle → **per-natal-body filter chips** (all + each point hit) → scrollable date-sorted list. Each row: `[transit body] [aspect glyph, family-colored] your [natal point]`, a one-line **gloss** distilled from the aspects PDF (nature + how it tends to land — hard = outer event/pressure, soft = an opening easy to miss, conjunction = a beginning, quintile = a creative urge, septile = a fated turn, aversions = a small realign), the exact date, a live countdown (`in 12d`), and a **family tag** (BEGIN / PRESSURE / OPENING / ADJUST / CREATE / FATED) in the wheel's aspect-family colors.
   - *Points back at the instrument:* tapping a row eases the transport to that exact jd (`_homeJd`, sheet closes so the wheel is seen arriving) — verified it settles on the tapped moment. A front-side door lives on the resting sky-lens ("transits to you →"). The list is **anchored at open-time** (cached; excluded from the per-tick sheet rebuild) so it doesn't churn while the instrument plays — only the countdown labels tick, off live `this.jd`.
   - *Still Opus's, unblocked by this:* transits-to-composite *surface* (engine already accepts the composite target; gate the door by seating when ♓ 6 lands). *Latent:* the `nextExactHits` scan runs on open/param-change only, but is synchronous — fine at 40 hits; revisit if the window ever widens.
   - **NEW TODO (July 11, user) — lunar transits as a first-class view.** The Moon is excluded from the main timeline by default (it floods a date-sorted list). But *by itself* a Moon-only transit view is genuinely useful — it's the daily-mood / fine-timing hand (catch a transit to the day), and it pairs naturally with the ♋ Moon panel (phase, VoC, mansions). Proposal: a dedicated **lunar-transits lens** — the same row/gloss/travel grammar, but transiting Moon only, over a short forward window (a few days), living in or beside ♋ Moon rather than ♐ (♐ = the slow far-seeing arc; ♋ = the fast lunar one). Ties to VoC: the Moon's *last* aspect before ingress is exactly the VoC boundary Sonnet's S4 computes, so the lunar-transits scan and the VoC scan share math. **Owner:** Opus for placement/copy (mirrors the ♐ lens just built), **Sonnet** for the short-window Moon scan + VoC hook. Sequence: after S4 (♋ VoC + mansions) so they land together.
5. ~~**Sonnet** — ♓ 5 threads + snap plumbing → **Opus** — ♓ 5 lens copy.~~ **DONE (July 11).** Plumbing (Sonnet) + `_beadStatus` lens copy (Opus, header gear line) both landed — see the ♓5 handoff note above.
6. ~~**Opus** — ♓ 6 B-plate mechanics under the hardened spec~~ **Plumbing DONE (July 11).** A person/event seated on the rete already froze it (`_reteFrozen`) but rendered on `rBody` — the sky's own track — which the law forbids (paper wearing light's radius) and which threw on every draw (`orb` was referenced but never defined in that block, so seating a person crashed the render loop silently). Fixed: B now gets its own recessed intaglio band (`rB = rN − 19`), violet-tagged ink (`185,174,224` for a person, pale `207,201,234` for an event, matching the existing bead/composite palette), its Ascendant engraved inline with the rest (O3 — angles as engravings, not rim occupants) rather than a separate rim badge. The aspect hub retreats `R−88 → R−102` while a second plate is seated (one-line change, `rAsp` now reads `this._reteFrozen()`). The inter-chart aspect thread family (A↔B) was already half-built in the old block — dashed threads from B's bodies to the A plate/composite bead, same engraved-dash grammar as the held-hand family, distinct violet/pale ink — it just needed the `orb` bug fixed and its origin moved from `rBody` to `rB`. Verified live: seated a test person via `_setRete`, confirmed no console error and sampled canvas pixels at the expected device-px radius (202, matching `rB` at the page's 2x backing scale) — violet ink present, band renders. **Lens copy still open** (synastry reading text/thresholds, mirroring the ♓5 split) — next Opus turn. Fable's violet *material* study (the intaglio recipe refinement) remains parked for a future budget; this pass used the existing gilt/stone recipe as the placeholder finish.
7. ~~**Anytime:** ring-layering (Sonnet)~~ **DONE (July 11, audit) — no code change needed.** Checked the law directly against the render: sky/transit ring draws at `rBody = R-58`, strictly outer to the natal/composite plate at `rN = rBody-17`; Vertex/MC/IC/DSC already get the O3 badge-only depth-of-field treatment (no disc, no ring, subordinate alpha) in the one place they're plotted (the sky-ring loop), and are absent by design from `_natalTargets()`/`this.comp` (bodies + As only) — so there's no second spot where an angle could dress as a body. Law holds everywhere it applies today. · S5 re-bundles + regression (Sonnet, last) — **DONE (July 11):** re-bundled `Orbo Astrolabe Standalone.html` from current master (transits, VoC/mansions, DSC, ♓5 all included) and pushed into `ios-wrapper/www/index.html` — the phone build was stale (pre-transits) and is now current.
8. **Parked behind everything:** radial chip ring · plate view (both Fable, both need fresh budget).

### Handoff (July 11) — two user-reported gaps, both fixed
- **♈ panel's natal toggle, reinstated as pure visibility.** O4 killed `showNatal` as a *seat* control (rightly — it competed with the seat picker). But that left no way to declutter the stone engraving at all once a chart is entered. Fix: `show.natal` (default true) is back in the ♈ panel as a plain on/off — it only gates the recessed-band/glyph render in `_draw()`, nothing else. Composite, threads, synastry, the sheet, `_natal()` — all untouched, so this can't reopen the three-doors bug.
- **Natal chart had no aspect reading with the sky off.** The wheel only ever drew an aspect web among the *transiting* bodies (`skyOn` gated) — the natal plate's own internal aspects (Sun trine Moon, etc.) were never drawn at all. Invisible normally (the sky-web + held-hand threads covered for it), but total silence once `rete:'off'` dropped the sky. Fix: a second, quieter web among `natT` points themselves at `rN`, same aspect/color grammar as the sky-web, gated on natal-visible + composite off (composite's gilt bead threads take over that job once engaged) + the existing `showWeb` setting — not on `skyOn`, so it holds in solo mode.

## Electional engine plan (July 12) — steps 5–7 of the master sequence

Grounded in the research doc (`uploads/coding electional astrology.md`) and in what already exists:
**`electional.js` is done** — 590 lines implementing the July spec: condition engine (Lilly dignities +
accidental), Moon module (via combusta, syzygy shadow, two VoC definitions, `nextMoonAspect` outcome),
topical dictionary (7 activities), Lots, fixed stars, field layer, arc-bound veto, `scoreMomentV2` /
`scoreDaySolo` / `scoreDayV2`. What's missing is the **browser build and the moon-side surfaces**.

### What the research doc changes (adopted)
1. **Two-layer split is already right.** framing/ephem = astronomy, electional = interpretation. Law:
   panel code never computes positions or scores ad hoc — it calls the engine and renders drivers.
2. **Severity classes become explicit.** Today a veto caps score at −3 and penalties just mix in. Add
   `severity: 'hard' | 'soft' | 'tiebreak'` to drivers. Hard failures render as *rejected because…*,
   never as a mysteriously low number. (Doc: hard exclusions / soft preferences / tie-breakers must not
   be flattened into one opaque score.)
3. **Doctrinal switches are first-class, back-side.** `vocDef` (hellenistic|lilly), orb, Moon-outcome
   horizon — these are *maker's choices*, so they live on the back (engrave side), persisted in
   settings, and **stamped into every result** (provenance: which VoC definition, which orb produced
   this reading). Two readings that disagree by doctrine must say so.
4. **Ranked windows with explanations, not one best time.** The windows lens returns top ~3 per span
   with rule traces and a "why this beats the neighbor" delta (`ComparisonArtifact` in the doc's terms —
   we render the changed drivers between adjacent candidates).
5. **Two-stage search.** Coarse grid (existing `samples`) misses short lunar windows (Moon ≈ 13°/day).
   Add a refine pass: re-sample ±1 step around each coarse peak at ~20-min resolution. No Brent needed —
   the score is bumpy, not smooth; halving steps suffice.
6. **Progressive explainability = the depth dial** (step 9 lands this for all lenses; electional is
   built ready for it): plain = one sentence + score; studied = top drivers with values; scholarly =
   full trace + provenance + source tags (rules already carry their lineage — Dorothean Moon
   corruptions, Lilly dignity points, Egyptian bounds; name them at scholarly depth).
7. **Honesty line.** Scholarly depth and the playable export carry one quiet sentence: symbolic
   tradition faithfully computed, not validated prediction. Also note our toy-ephemeris precision there.

**Not adopted** (out of scope for an in-browser instrument): Swiss Ephemeris/JPL validation, tzdb
history, topocentric mode, sidereal/ayanamshas, external rule-engine libs. Our `ephem.js` is the fixed
astronomy layer; its precision statement is part of the scholarly provenance, not a work item.

### Electional 1 — browser build + score-the-now
- Generate `electional.browser.js` from `electional.js` the same way as the other four (browser-global
  `OrboElectional`, imports resolved against `OrboFraming`). `.js` stays source of truth.
- **Gate = seating** (sun/moon law: interpretation needs a natal; empty states point at ♈).
- **Sheet header chip** (moon side): small score for *now* under the current activity profile —
  `now +1.2 · asking` — tap opens the breakdown as a sheet mode (`sheet:'election'`), same
  grammar as the transits lens: drivers as rows, severity-tagged, tap-nothing (it reads the present).
- **Save dialog line**: above the kind chips, one line scoring the moment being saved —
  score + outcome aspect (`☽ △ ♃ — resolves well`). Costs one `scoreMomentV2` call, cached per jd.
- Engine calls are on-demand (open/scrub-settle), never per-tick.

### Electional 2 — outcome aspect on memory pins
- `_pinMoment` / `_saveChart('memory')` also call `nextMoonAspect` at the pinned jd; store
  `outcome: {txt, harmony, jd}` in the entry. ♒ rows get a third sub-line: `resolves: ☽ △ ♀ · in 9h`,
  colored by harmony. Older pins without `outcome` backfill lazily on panel open.
- This is the classical payoff made visible: the Moon's next perfection *is* the verdict on the moment
  you marked.

### Electional 3 — "when should I…" windows lens
- Lives in the sheet beside the ♐ ledger (a lens mode, not a new rim slot — the ledger door already
  owns far-seeing time). Activity chips = the 7 `TOPICS`. Span: next 7 days default, 14/30 on demand.
- Scan = `scoreDaySolo` per day + the refine pass (adopted §5). Render: ranked windows, score bar,
  one-line top driver, outcome aspect; hard-rejected windows collapsed under *"rejected: …"* with the
  hard driver named. Tap a window → ease the transport to its jd (sheet closes, wheel arrives — same
  travel grammar as transits rows).
- Anchored at open-time like the transits list; recompute on chip/span change only.

### Decisions (user, July 12)
1. **VoC doctrine: Lilly first, Hellenistic fallback.** Judge windows under Lilly; and if the 7-day span
   yields no clean window because of the first-house (actor) ruler, say so plainly — *"no clean window
   this week: the actor's ruler is impeded throughout"* — and still surface the **next-best** times in
   the span (best-of-the-bad, ranked, with the impediment named on each). Never return an empty answer.
2. Score-chip visibility: undecided — build it behind a back-side switch, default to showing only while
   the save dialog / election lens is open; revisit after it's felt.
3. Score-the-now profile: **always 'ask'** (neutral default), chips switch it per-look, no persistence.
4. Windows span: **7 days** default (14/30 on demand stays).

## The Almanac — ♐ fusion console + the spine's civil-time reading (July 16, 2026)
*Agreed in conversation; plan recorded before code.*

**Theory:** the almanac is the **timespine read in civil time** — a flat, month/agenda projection
of the same spine the ♒ ammonite will one day render organically. Not a new store, not a fourth
feature: one spine, two projections. **Fuse** is the verb — streams of interpretive light the
user chooses to lay onto the spine. Nothing rides unfused (per user: even beads are fusible, not
automatic). This keeps the July 14 law intact: ZR never becomes ♒'s chamber unit — a fusion is
light over the shell, never a chamber wall.

**Renames (user decision):**
- ♎ Scroll → **♎ Ledger** (the collector was always a ledger of charts; the word migrates here).
- ♐ Transits → **♐ Almanac**. The old ♐ door "open the ledger →" dies with the rename — the
  transits *reading* keeps living as the pane's `transits` lens, unchanged.

**♐ Almanac = the fusion console (maker's side):** one row per fusible stream, each with a fuse
toggle + its single doctrine choice inline:
1. **transits** — target chips (natal / composite) fold in from the old ♐ panel.
2. **releasing** — level choice: L2 chapter starts (markers) · L3 · L4 (chapters as spans).
   Needs natal DNA.
3. **intersections** — rides only while a person is seated on the rete (greyed otherwise).
4. **beads** — ♒ pins + ledger events/horaries (fusible like everything else, per user).
5. *Designed-for, not built now:* lunar phases/VoC · election windows (registry takes five).
Plus: "+ add to lunar pane" (opt-in, `paneLenses` pattern — user decision) and a month `.ics`
export verb (the user's iCal workflow came FROM our exports; keep the door open).

**The pane lens (moon side):** chip `almanac`, pinned opt-in. Two forms, switched by sub-chips
on the sheet itself (the pane's own sub-menu grammar; form-of-reading is a moon property):
- **upcoming** (default) — agenda of the days ahead of the held frame: day headers, pill rows
  color-coded per stream, ZR chapters as banner rows while a chapter spans.
- **month** — compact 7-col dot grid (dots per stream, held day ringed, ‹ › paging), tap a day
  → its docket lists below. User flagged the grid may be too big for the pane — build upcoming
  first, month second, judge on the glass.
- Every row tap-travels the instrument (existing cxRows/luRows pattern). Stream colors from the
  house palette: transits #4da4d9 · releasing #e8ab41 · intersections #dd8f78 · beads #beb8e2.

**State:** persisted `fused: []` (stream ids — spine doctrine, independent of pane pinning),
`almZr: {l2,l3,l4}`, `almForm`. Month-anchored caches per stream (the transit exact-scan is the
only heavy one; mirror `_txCache`'s anchor pattern).

---

## Timespine — the ♒ Aquarius spiral (July 12, 2026)
*Talking phase. No code yet — this is the record of where the conversation landed, to react to.*

The natal seed doesn't stay a point — it unspools. ♒ Aquarius (the panel slot already flagged
"dormant / future skins" in earlier passes) becomes its home: a **timespine**, rendered as an
**ammonite spiral** — the shell's logic (one continuous chamber, growing outward, each whorl
larger than the last) *is* a life's time, not a decoration borrowed from nature.

**Confirmed:**
- **Form = ammonite spiral**, drawn in the ♒ tab.
- **The natal engraving is the first fixed point** on the spine — but the spine itself **extends
  pre-birth**. Birth doesn't start the shell; it's the first chamber wall someone actually built.
- **♎ Libra is the collector, ♒ is the arranger.** Entries/list items made in ♎ (People, Events)
  become **beads threaded onto the spine** in ♒ — same two-verb split as the composite work
  (collect vs. compose), now applied to biographical time instead of a single moment. Events and
  horary both qualify as beads.
- **Beads expand.** A bead isn't a fixed dot — it opens (detail, not just a marker).
- **No scrub bar, ever.** The scrub-transport law that governs the front wheel does NOT apply
  here. **Pinch-to-zoom is the only navigation tool** on the spine — you don't drag through a
  life, you zoom into it, the way you'd approach an actual ammonite fossil.
- **Click bead + pinch = unfurl**, with **the bead as the midpoint** of the unfurl — zooming in
  centers on what you grabbed, not on the spiral's origin or its current edge.
- **"Fossilize" replaces "pin."** The capture verb gets a name that matches the material — a
  moment doesn't get pinned to a corkboard, it gets fossilized into the shell (permanent, mineral,
  part of the growth record).
- **An empty spiral is fine.** No beads yet ≠ broken state — the shell exists before it's full;
  time fills it as you go. (Same "no empty state" instinct as the front face, applied here: you
  don't wait to have enough life-events to justify opening ♒.)

**Open:**
1. **Pre-birth content** — what actually lives on the pre-natal coils? Two candidates in tension:
   *other people's seeds* (parents, ancestors — their charts as the pre-history) vs. *prenatal
   syzygy* (the lunation before birth, a real astrological technique with its own signification).
   Not necessarily exclusive, but the spine's inner whorls need a definite occupant before this
   builds.
2. **Chamber unit** — does the shell divide into a **fixed gear** (uniform time slices, like the
   front's planet-gear ratios) or **organic thresholds** (chambers sized by what actually happened —
   a life's own rhythm, not a metronome)? This is the ammonite metaphor's load-bearing choice:
   real shells grow chambers of increasing but irregular size as the animal ages, which argues for
   organic — but "organic" needs an actual rule before it's buildable, not just a vibe.
3. **Recenter behavior** — when you recenter/refocus the spiral, does it **keep one coil** (the
   view just reframes within the existing shell) or **bud a daughter spiral** (a new shell grows
   from the recenter point, nested or attached)? Ties into #2 — daughter spirals only make sense
   if chambers are organic thresholds, not a fixed gear.
4. **Tagging mechanics** — how a person and an event connect to each other on the spine (a bead
   for "dinner with X" needs to reference the "X" bead). Not yet designed.

**Next:** visual exploration of the ammonite display itself (chamber rendering, whorl spacing,
bead placement on the shell wall, the fossilize gesture's look) — still no code, sketching only.

---

### Handoff (July 11) — natal points/aspects now match the enabled set
`_natalTargets()` mapped a fixed `this.BODIES` (the 10 core planets) regardless of what the user had actually turned on — so MC, IC, DSC, North Node, Vertex, Fortune, Chiron, Lilith, the four asteroids could all light up the *live sky* via their toggles but never appeared on the natal plate, in its aspects, in its threads, or in synastry. Root cause was two-layered: (1) `_natal()` only called `eph.positions(njd)`, which omits the angle-dependent extras (MC/IC/DSC/Vertex/Fortune need asc/mc) that `_posAt` already computes for the live sky — fixed by mirroring that exact computation for the natal jd/lat/lon. (2) `_natalTargets()` itself listed `this.BODIES` instead of `this._active()` — fixed to map the same active list the wheel's own ring uses (South Node still excluded from the target list, matching every other aspect-computation site in the file, where it's treated as Node's axis echo, never its own participant). Angle points (MC/IC/DSC/Vertex) get the bold-sans label treatment on the plate instead of the symbol font (GLYPH already held the right short strings — 'MC'/'IC'/'Ds'/'Vx' — just needed the font swap). Everything downstream that already consumed `_natalTargets()` — the natal ring engraving, the new natal-internal aspect web, held-hand→natal threads, composite-bead snap, ♓6 synastry threads, tap-to-sheet — picked this up for free. Verified live: enabled all extras + a test natal chart, confirmed `_natalTargets()` returns real longitudes for all of them (Node, Lilith, Chiron, asteroids, Fortune, Vertex, MC, IC, DSC) with no console errors.

---

## Handoff (July 12) — AstroDNA + zodiacal releasing engines built (data layer only)

Triggered by a request to design the zodiacal releasing engine (research doc:
`uploads/deep-research-report(zodiacal releasing)-63644528.md`). Conversation surfaced a
reference implementation the user had already run externally — a day-by-day 2026 peak/overlap
table (`uploads/2026_all_lots_peak_daily_counts.csv`) and its compressed ranges
(`...peak_overlap_ranges...pdf`) — which settled several open questions before any code was
written, then a second pasted script (`astrodna.py`) reframed the whole architecture. Two new
engine files exist now; **nothing else in the project was touched** — no UI, no sheet lens, no
wiring into `Orbo Astrolabe.dc.html`. That boundary was explicit and repeated by the user
multiple times this pass; respect it until they say otherwise.

### The architecture decision (this is the important part)

**AstroDNA is the canonical encoding. Zodiacal releasing — and eventually every other
interpretive engine in this project — decodes from it rather than re-deriving positions
independently from raw ephemeris.** One snapshot, computed once at natal engraving; every
consumer reads the same numbers. This is a real reordering of the "moon view" pattern used
elsewhere in this doc (transits, electional, composite): those all currently call `ephem.js`
directly per their own cache. AstroDNA is meant to sit underneath all of them going forward —
**not done yet** (see "explicitly deferred" below), but zodiacal releasing is the first thing
built against it, and it was built as a decoder from day one specifically so it wouldn't need
retrofitting.

### `astrodna.js` / `astrodna.browser.js` — the encoder

Ported from the user's `astrodna.py` (12-node numerical sequence, aspects, stelliums,
elemental balance, chart ruler) onto this project's own `ephem.js` in place of Swiss
Ephemeris. Full feature set built in one pass (user: "the full astrodna with feature set is
first especially because we have all of it").

- **The encoding**: 12 nodes (Sun, Moon, Ascendant primary; Mercury, Venus, Mars, Jupiter,
  Saturn, Uranus, Neptune, Pluto, Node secondary) each collapse to one integer — 1-360 direct,
  361-720 retrograde. That compact integer is "the sequence" / the genome's identity.
- **Precision decision** (a deliberate deviation from the reference script, not asked
  permission for, just handled): every node ALSO keeps its full-precision float longitude
  alongside the integer, because things that decode through this later — ZR's sign-boundary
  timing, future transit exact-hit timing — need better than whole-degree accuracy. Only the
  compact integer is the "sequence"; nothing downstream loses precision reading `nodes`.
- Retrograde read via centered finite difference (±6h) on longitude — no dependency on a
  separate motion table, matching this project's self-contained/verifiable convention.
- Aspects (5 majors, script's own orbs), stelliums (sign-based + degree-cluster, ported
  faithfully including the reference script's simplified non-partition clustering), elemental
  balance (weighted, primary nodes 3x), chart ruler (traditional rulerships — Mars/Scorpio,
  Saturn/Aquarius, not modern) — all included.
- **Verified** against a sample chart (1990-06-15 14:30 -5, 43.34N/90.38W): Sun 24°Gem, Moon
  19°Pis, Asc 12°Lib all check out; a real Saturn-Uranus-Neptune stellium in Capricorn
  surfaced correctly (a documented fact of 1988-90 skies) — good sign the encoder's honest.

### `zr.js` / `zr.browser.js` — zodiacal releasing, decoding from AstroDNA

- **Eight lots at parity** (user, after reviewing the CSV): Fortune, Spirit, Eros, Necessity,
  Courage, Victory, Nemesis, **Death**. Death is not in the research doc's seven Hermetic
  lots — used a documented classical variant (8th-whole-sign-cusp / Moon), flagged explicitly
  to the user as the one formula without a doc citation to check against. **Still open: user
  sign-off on the Death formula**, or a different source's variant if they have one in mind.
- **Bundling**: lots sharing a natal start sign run one identical schedule forever (the user's
  own chart has Fortune, Eros, and Courage all landing in the 4th house/same sign — "tying
  those areas of life together"). `findBundles()` detects this per-chart rather than assuming
  any fixed grouping, and the peak-overlap scanner treats a bundle as one track.
- **Two peak definitions, both always computed** (user: "what's the harm in doing both?"):
  `peakTrueAngles` — the chart's real whole-sign angles (Ascendant's sign + 4th/7th/10th from
  it, derived purely from Asc — this matches the user's own CSV/PDF sample exactly, which
  used this exact quadrature rather than actual MC placement) — and `peakBrennanSelf` —
  Brennan's angular-triad reading, each lot's own natal starting sign + its own +3/+6/+9.
  Neither is discarded; nothing forces a choice.
- **"Zodiacal time, not Roman time"** (user's framing, and the better answer than either
  option originally offered): L1 (years) and L2 (months) are measured in the mean tropical
  year (365.2422 days) and its twelfth, added as raw day-counts onto `jd` — never civil/
  Gregorian calendar arithmetic. Gregorian dates are derived from `jd` only for display
  labels, matching this project's own north star (sky-state is the truth, clock-time is the
  derived shadow) applied to ZR specifically.
- **Generic level builder** (`buildLevel`) serves L1 through L4 identically — no per-level
  special-casing. Loosing-of-the-bond only applies to a nested level (never the unbounded
  top level): a full 12-sign circuit completing before its containing period ends flips the
  next circuit to the OPPOSITE of whichever sign started the one just finished, alternating on
  repeat. **Verified against the research doc's own worked example**: an L2 circuit starting
  Cancer totals exactly 211 months (17y7m) before flipping to Capricorn — matches the doc's
  continuation precisely.
- **`scanPeakOverlaps()`** mirrors the user's reference CSV/PDF shape directly: a daily table
  (per-bundle current sign + peak flag) and compressed contiguous ranges (start/end date, days,
  max simultaneous-peak count, example lot combinations) — the "peak moments" feature the whole
  pass was oriented around.
- **Verified**: all seven Hermetic lot formulas reproduce the research doc's worked numerical
  example exactly (Fortune 90°, Spirit 0°, Eros 117°, Necessity 327°, Courage 197°, Victory
  145°, Nemesis 162°) on the day branch. One thing surfaced along the way, not a bug: the doc's
  own worked example chart isn't actually sect-consistent by the standard rule (Sun in houses
  7-12 = day) — it's geometrically a night chart despite being labeled diurnal. Our sect
  derivation (same convention already used elsewhere in this file) is correct; the doc's
  illustrative numbers just weren't self-consistent. Confirmed by forcing the day branch
  manually and getting an exact match.

### Explicitly deferred / NOT done this pass (boundaries the user set, not gaps to silently fill)

- **No UI, no sheet lens, nothing wired into `Orbo Astrolabe.dc.html`.** Both engines are
  standalone files only. Wiring is a distinct future step once surfacing is decided.
- **No migration of the existing engines** (`transits.js`, `electional.js`,
  `framing.js`/composite) onto AstroDNA. The end-state the user described has everything
  decoding from AstroDNA, but this pass deliberately scoped that out to avoid destabilizing
  already-verified systems while chasing the architecture everywhere at once — a later,
  separate pass.
- **Timespine (♒) itself is untouched.** AstroDNA becomes its seed (the natal snapshot as the
  spine's first fixed point) and ZR's chapters are the natural answer to the design map's
  long-open "organic chamber unit" question (see the July 12 Timespine section above) — but
  that's a conceptual fit, not built. The ammonite rendering, pinch-zoom, fossilize gesture,
  pre-birth coils, and daughter-spiral recentering are all still fully open per that section.

### Still-open decisions before any wiring pass

1. **Death lot formula** — needs the user's sign-off or a source correction.
2. **Surfacing/entry point** — proposed as a sheet lens off ♈ Natal (matching the Transits/
   Composite door pattern), unconfirmed. Also unconfirmed: how much nesting depth to expose by
   default (L1+L2 vs full L1-L4) and which peak definition leads (`trueAngles` proposed as
   primary, `brennanSelf` as a scholarly-depth secondary reading).
3. **`scanPeakOverlaps`'s `minCount` default** — used `2` as a placeholder (matches the
   granularity of ranges the user's own PDF export showed), not confirmed as the right cutoff.
4. **Timespine data-structure** — connecting ZR's chapter/period objects to actual spine
   "chambers" needs a schema, once the ammonite UI work resumes.
5. **The broader AstroDNA migration** for `transits.js`/`electional.js`/`framing.js` — deferred
   to its own pass per above, not forgotten.

---

## Decisions (July 14) — scroll taxonomy settled + AAF/save-flow wired

**♎ scroll taxonomy (user-decided, now law):** three kinds only — **person** (a natal),
**event** (covers most things that happened), **horary** (a question). `pp` stays internal
(minted, never chosen). **Subtype** is where entries get specific and interconnect —
pure metadata: it never changes computation, sorts/threads the ♒ timespine, and shows
only on tap/detail (hover title on roster rows; NO row badges, per user). `null` subtype
= the plain default (natal / moment). Vocabulary: person → entity, fictional; event →
lunation, return, election, ingress, communication, **pin**; horary → none.
- **Memory folds in:** a ♒ pin IS `kind:'event', subtype:'pin'` (storage still
  `state.memory` until the Ammonite pass merges the stores — the timespine is about ALL
  saved things, per user; ZR is NOT the chamber unit and stays out of ♒ entirely).
- **Save flow** (front, long-press center): three kind chips, then a subtype chip row
  pops per kind. Event+pin routes to ♒ memory; everything else joins the ♎ roster.
- **relatesTo:** name-strings stored as metadata for now; chosen surfacings (roster
  detail link line, held-highlight, ♒ threads) are later passes.
- **Tabula:** ♏ keeps Objects; ZR moves in later when built. ZR is tabled.

**AAF import wired into the astrolabe (♎ panel, maker's side)** — NOT Composite Framing
v2, which is archived (`archive/Composite Framing v2 2026-07-14.dc.html`) and reference-
only. `aaf.browser.js` generated from aaf.js (attachAstroDNA dropped — records flow
through `_sequence()`, the app's own AstroDNA gateway). Laws honored: `jd` canonical,
LMT/dst metadata, dedup on (name, jd-to-the-minute). moment→event, entity/fictional→
person-with-subtype. `Handoff to Fable - AAF Import.md` still points at CF v2 — amend it.

## V0.78 (July 15–16) — the lunar pane: L1–L9, Opus/Fable/Sonnet

*Full brief: `specs/Lunar Pane - Delegation Briefs (2026-07-15).md`. Nine user todos on the pull-up
sheet, now renamed **the lunar pane** (L1 — rename only, same rise/eclipse/occlusion behavior).*

**Opus — the lens registry (L3 spec, L4, L5/L6 model):**
- **L4** absorbed the Moon-only `lunar` tab into Transits — the ♋ "fast hand" door now opens
  `sheet:'transits'` with `txMoon:true` pre-set, so the fast-hand reading still has a front door.
  `_sheetDataLunar`/`sheetLunar` left dormant, unreachable.
- **L5/L6** built the "Add to lunar pane" opt-in model: `state.paneLenses` (persisted, default empty —
  clutter-free by design), `_togglePaneLens(id)`, ♏ Timing pills for releasing + windows
  (`toggleZrPane`/`toggleElPane`, gold when pinned). Election is now a first-class arc lens (previously
  door-only).
- **L3** respecced "the sky" as a positions register — `_sheetDataSky` now returns
  `_specRows(this.pos, this.asc)`; big three, moon-phase disc, and "tightening now" retired per the user.

**Fable — L7 + L8, the reflected-materials nav:**
- **L7** — the primary lens switcher is now a **grab-drag rotating ring** (mimics the rete): the active
  lens rests lit at a top-center crown detent, momentum + snap on release, still tap.
- **L8** — secondary options ride a **second concentric arc** underneath (mimics the plate): free-slide,
  clamped, no detent. All three option lenses (transits/windows/releasing) wired in. Redundant per-sheet
  titles removed everywhere — the lit crown label is the title now.
- Silver corona law kept; materials/colors intentionally untouched (deferred to Sonnet's L9).

**Sonnet — L2, L3 build, L9, regression:**
- **L2** — plate/rete/sky register rows: the name text now renders in the row's own element color
  (`{{ r.gc }}`, matching the glyph) instead of flat `#f2f0fc`, so glyph + name read as one
  element-colored unit. HSE↔dispositor column spacing widened (gap 16→24px, hse 16→20px, dispositor
  min-width 52→56px) to stop the cluster crowding.
- **L3 build** — mirrored the sheetPlate register markup into the new `sheetSky` template; wired
  `skyRows`/`skyTitle`/`skyOk` in `renderVals`.
- **L9** — brightened the muted-purple token family everywhere in the lunar pane's sheet templates and
  registers: `#5a5090→#8478b8`, `#8f86c0→#b3ace0`, `#6f66a3→#9791c9` (captions, sub-text, empty-states,
  register headers/positions); row separators `rgba(214,222,240,0.08)→0.16` so register rows read as
  rows. One color language kept — no new hues, gold emphasis untouched.
- Regression pass clean; re-bundled as `export/Orbo Astrolabe V0.78.html` and pushed to
  `ios-wrapper/www/index.html`.

---

## Handoff (July 14) — zodiacal releasing wired in (♏ Timing + the sheet)

The July 12 boundary ("no UI, no wiring") was lifted by the user. Decisions taken this pass:
sortable by **level** (the L1→L4 column browser IS the level sort) and **lot** (chips);
**Spirit + Fortune central**, other 6 behind a "+ the other lots" chip; **both peak defs**
computed, **trueAngles primary** with a maker's-side toggle on ♏; **Death lot kept**
(8th-cusp/Moon variant); **now highlighted + tap-to-travel**; **♏ = setup/config, sheet =
the reading** (sun/moon law). Reference visual: `uploads/Screenshot 2026-07-14 at 9.42.45 PM.png`.

- **`zr.browser.js` generated** from zr.js (globals: `__ORBO_EPH.norm360`, `__ORBO_ASTRODNA.SIGNS`
  → `window.__ORBO_ZR`), loaded after astrodna.browser.js; `this.zr` via `_waitGlobal`.
- **Decodes from AstroDNA**: `_zrData()` reads `_natalDna()` (never raw ephemeris), caches
  lots/bundles/angle-sets per natal jd. Schedules rebuild per render — pure Valens arithmetic.
- **♏ Timing panel** (maker's side): gilt "chapters of the life — releasing →" door (mirrors the
  election door; empty state points at ♈) + the peak-doctrine chips ("the chart's angles" /
  "the lot's own"), persisted as `zrPeakDef`; `zrLot` persists too; section dot lights when
  either deviates from default (Spirit / trueAngles).
- **Sheet mode `sheet:'zr'`** (the reading, moon side): L1→L4 Miller columns per the screenshot —
  sign glyph in element color + start date per row; **gold = the chapter containing now** (per
  level); **teal outline = peak** under the primary def; **`cu` badge** = peak under the secondary
  only; **`LB` badge** = loosing of the bond (detected as a sign-sequence discontinuity, level >1);
  tap a period to open its children, **tap the open one again to travel there** (transits-row
  grammar: live off, sheet closes, `_homeJd` eases). Lot chips re-anchor the whole browser;
  bundle-mates surface as a "shares its schedule with…" line. Scholarly depth carries the
  provenance + honesty line. Reachable from the ♏ door and as a "releasing" view chip beside
  transits/lunar (sky-rete seating + natal required).
- **Not done / still open:** `scanPeakOverlaps` has no surface yet (minCount=2 still a
  placeholder); ZR↔timespine chamber schema untouched (ZR stays out of ♒ per July 14 law);
  broader AstroDNA migration of transits/electional/framing still its own pass.

**Also this pass:** rete/plate boundary-line fix (sky notches hang down to, plate notches
rise up to, one shared circle at rN+11; rBody R−53, rN R−75 unchanged) · ♈ "sky → natal
threads" ambient toggle · ♈ date+time on one line · picker-indicator margin reset.

---

## AstroDNA is the decode surface — the frame both plans below sit inside
*(July 16) The load-bearing architecture, per `astrodna.js` + the AAF Translation Protocol. Both plans below are **expressions of the genome**, never parallel re-derivations of the sky.*

- **One genome, one decode.** `buildAstroDNA(jd, lat, lon)` is the canonical natal sequence; ZR, the timespine, and the interpretive engines **decode from it** rather than each re-deriving positions from raw ephemeris. ZR already obeys this (`zr.js` `computeLots(dna)` reads `dna.nodes`; peak sets from `trueAngleSigns(dna)` / `brennanAngleSigns`). Every roster chart (people, moments, and AAF-imported charts via `attachAstroDNA`) carries its own `.dna` + `.sequence`, so composites/synastry decode the same way.
- **Dual precision — read the right half.** Each of the 12 nodes has a compact integer *gene* (1–360 direct / 361–720 retrograde, whole-degree — the identity `sequence`) **and** a full-precision float `longitude` beside it. Identity/comparison uses the gene; **timing** (ZR sign-boundary crossings, transit exact hits) MUST read `dna.nodes[x].longitude` — never the gene. Both plans below read through the full-precision surface for anything dated.
- **The elemental palette is AstroDNA's, shared app-wide.** `SIGN_ELEMENTS` (fire/earth/air/water) is the canonical sign→element map; `dna.elemental` is the chart's own weighted balance (primary nodes 3×, classical 1×, outer/Node 0.5×) with a `dominant`. The wheel's `ELEM`, the ZR sign glyphs, and the Almanac wash must all draw from this one four-element palette — the genome is the source of the colors, not a separate table.

## Plan (July 16, 2026) — RELEASING becomes an accordion, on the app's own gesture grammar
*Talked out, not yet built. Supersedes the July-14 "column browser" + tap-to-travel model for the RELEASING pane view. **A reading of the genome:** the lot longitudes, chapter timing, and peak sets are all decoded from AstroDNA (`computeLots(dna)`, full-precision `dna.nodes[x].longitude` for sign-boundary timing), never re-derived.*

**Diagnosis.** The current RELEASING view (`sheetZr` / `zrCols`) renders L1→L4 as four stacked flat sections, and the tap handler conflates two jobs: first tap = select-and-build-sublevel, second tap = travel the wheel to that date. Because the current chapter opens **pre-selected as "now,"** the user's first tap on it registers as the second tap and fires the travel — so the drill never gets a turn, and tapping "just zooms the astrolabe." That travel-on-tap is on the wrong gesture; the whole browser needs reshaping into a drill, not columns.

**The shape — one accordion tree (the pane's Plate anatomy).**
- **No level picker.** Always the full **L1→L4** tree (years → months → days → hours). Drop the L1/L2/L3/L4 chooser entirely.
- **Opens expanded down today's path**, gold-trailed: current L1 chapter open → current L2 month open inside it → current L3 day → current L4 hour. You land standing in the present.
- **Accordion-strict, now-tracking.** One path open at a time — opening a different period collapses its siblings. User can collapse/climb away freely; re-opening re-tracks to now.
- Tap a period → **unfold / collapse** its children in place (indented one step under it). This is the *only* thing tap does now.
- Peak-outline / `cu` / `LB` badges **carry down every level** (keep — decided July 16).
- Lot chips + peak-definition doctrine stay as-is — that's ♏ Timing's maker choice (sun/moon law); the pane only reads it. Bundle "shares its schedule with…" note stays.

**The gestures — spend the grammar we already have, no button strip.**
- **Tap** → unfold / collapse. (drill)
- **Double-tap a period → travel the astrolabe to its start moment.** This is the app's established "jump in time" verb (double-tap clock = home, double-tap As = horizon lock). Moving travel here — off single-tap — is what fixes the confusion. On travel: `live=false`, pane recedes, `_homeJd` eases to the period start (existing transits-row grammar, just re-bound to double-tap).
- **Swipe a row sideways (toward the pane edge) → send it to the Almanac.** The drag-to-promote verb applied to a moment — pushing the chapter out of the reading and onto the calendar. Horizontal swipe doesn't fight the accordion's vertical scroll; a ♐/calendar glyph surfaces from under the row during the drag; release lands the Almanac scrolled to that date.
- **Long-press a period → mark it** (pin to ♒ Archive, or mark+calendar = .ics) — its existing front-instrument meaning, now available on a life-chapter. *(Nice-to-have; can trail the first two.)*
- **One-time fading hint on a row** ("double-tap → wheel · swipe → almanac"), same pattern as the sheet's how-to hints.

**Build order & dependencies.**
1. Reshape `zrCols` → a nested accordion model (parent holds its expanded children; `zrSel` becomes the open-path, auto-seeded to now).
2. Rebind gestures: tap=unfold, double-tap=travel-wheel, (long-press=mark).
3. Wire the **swipe→Almanac** destination — but it can't fully land until the Almanac view is fixed (cross-pane jump into a pane with its own issues). Build the gesture + target hook; connect the landing in the Almanac pass.
4. Keep RELEASING as its own pane arc (decided A — do **not** collapse it into the Almanac; the Almanac has separate issues). Whether Timing *also* fuses into the Almanac is the Almanac pass's question.

**Next:** walk the Almanac's issues the same way before building, since the swipe destination and the "does Timing fuse into the Almanac too" question both depend on where the Almanac lands.

---

## Plan (July 16, 2026) — the Almanac: calendar-scroll + day view, with the peak-overlap elemental wash
*Talked out against the user's iCal (month grid + single-day timeline as inspiration) and the current Almanac (`upcoming` agenda + `month` dot-grid). Not yet built. **A reading of the genome:** the wash's peaks (`scanPeakOverlaps`) and every element are decoded from AstroDNA — `computeLots(dna)`, `SIGN_ELEMENTS`, `dna.elemental` — not a parallel color/position table.*

**Diagnosis.** The current Almanac has two forms — `upcoming` (a forward agenda of timed transit hits) and `month` (a grid where each day is a single has-events dot). The grid is a **dead end: tapping a day does nothing.** iCal's whole structure is month → **tap a day → single-day reading**; the Almanac is missing that day view, and the month grid can't fit a pane at iCal's chip density anyway.

**The shape — two forms, a coarse→fine pair (weekly/multi-day view dropped entirely).**

1. **Calendar — a continuous vertical scroll through the year.** Months stacked head-to-tail (JULY 2026 → AUGUST 2026 → …), each a 7-column week grid. Scroll up = past, down = future. **Opens anchored on today** (today ringed), same as the ZR accordion opens on now. This is the iOS/Fantastical continuous-scroll pattern — it fits the half-screen pane because the grid never shrinks to fit, it just keeps flowing. Tap a day → the day view. (Solves "doesn't fit on the pane" without cramming.)

2. **Day — the reading.** Tap a day → its single-day view: a **time-ordered list** of that day's fused events (list, *not* an hourly rail — the rail's empty hours waste half the pane). Back returns to the scroll at that month. Rows use — and extend — the existing `upcoming` grammar (glyph · aspect · "your Moon" / subtitle "transit · exact" / right-aligned time), but carry **all** fused streams color-coded by stream (transits, releasing level-changes, intersections, beads), not transits only.

3. **Keep `upcoming` for now.** Build calendar+day alongside it; retire `upcoming` later only if it proves redundant against the day view. (User's call — low-risk order.)

**The calendar's coloring — the peak-overlap elemental wash (this is the point of the whole pass).**
- Surfaces `scanPeakOverlaps` (zr.js), which until now had **no surface** (design map has flagged "minCount=2 still a placeholder"). The CSV `2026_all_lots_peak_overlap_ranges.csv` is its output: the ~50 ranges in 2026 where ≥2 lot-bundles peak simultaneously, with `max_peak_lot_count` (2–5).
- **Every day gets a color** — a **pale** elemental tint (its base elemental character). **Peak days deepen to the saturated hue of the same element** — pale gold vs deep gold — so intensity is *visually weighted*: the eye reads the lit stretches (e.g. Apr 11–25's 15-day, up-to-5-lot blaze; Jan 11–19; Nov 7–16; the Jul 11–17 cluster) as deep bands against pale ordinary time.
- **Element is decoded from AstroDNA, not a parallel map.** Each peaking lot is decoded via `computeLots(dna)` (full-precision), its sign taken from that longitude, its element from `SIGN_ELEMENTS[sign]` — the same canonical fire/earth/air/water palette the wheel's `ELEM` and the ZR glyphs draw from. Peaks are unambiguous (a peaking lot sits in one sign → one element); co-peaking lots of different elements blend, and depth follows `max_peak_lot_count` (more overlap = deeper, capped so a 5-lot day deepens rather than blows out). The peak-count weighting deliberately echoes the genome's own weighted balance (primary 3× / classical 1× / outer 0.5×).
- **White date always on top** of the colored square (user's #3) — legible at any saturation.
- **Peak definition flows from ♏ Timing** (`trueAngles` vs `brennanSelf`) — same doctrine, decoded from the same `dna` (`trueAngleSigns(dna)` / `brennanAngleSigns`), that drives the accordion's peak-outline/`cu` badges drives the wash. One source. (CSV is `trueAngles`, minCount=2.)
- **Peaks thus appear twice, two faces of one dataset:** peak-outline/`cu` on individual rows in the RELEASING accordion (structure, per-lot, zodiacal time) and the elemental wash across the calendar (weather, collective, civil time). Sun/moon logic — one light, refracted two ways.

**Open doctrine to pin at build:** what sets a **non-peak** day's *base* pale element (peaks are defined; ordinary days need a rule). Two AstroDNA-native candidates, both already computed: **(a)** the chart's own `dna.elemental.dominant` as a single pale baseline everywhere ("your elemental nature colors ordinary time; peaks flare in the peaking lots' elements") — simplest, and honest to the genome; **(b)** the active releasing chapter of the **primary lot** (♏'s selected lot, default Spirit) — its L1 sign (`SIGN_ELEMENTS`) gives long calm pale bands ("seasons of the life"), within which peak days flare deep. Lean (a) for a stable baseline, (b) if you want the base itself to drift with the chapter. Confirm when building.

**Staging.** Now: calendar (vertical-scroll year, anchored today) + day view (time-ordered list, all streams) + keep `upcoming`; simple density marks on cells as a placeholder. Target: replace the density marks with the pale-base / deep-peak elemental wash. The ZR swipe-to-almanac gesture lands on the **day view** at the swiped date (the cross-pane hook from the ZR plan).

---

## Delegation pass (July 16, 2026) — Fable / Opus / Sonnet
*Best use of tokens + time, following the established pattern: Opus lays the model, geometry, and correctness-critical decode; Sonnet renders the rote markup once the model is fixed; Fable spends its budget purely on feel, last, on a settled structure. Sequence per feature: **Opus → Sonnet → Fable.***

**Opus (architecture, decode correctness, geometry, state machines) — do first, gates everything:**
- Reshape `zrCols` → the nested accordion data model: open-path (`zrSel` → path), auto-seed to now, accordion-strict now-tracking, badges carried down every level. (todo 1)
- AstroDNA decode discipline across both plans: lots via `computeLots(dna)`, **timing via full-precision `dna.nodes[x].longitude`** (never the gene), peak sets via `trueAngleSigns`/`brennanAngleSigns`. (todos 9, 11)
- Gesture state machine: double-tap detection, **swipe-vs-vertical-scroll disambiguation**, travel-to-period hook (`live=false`, `_homeJd` ease), long-press→mark. (todo 2 logic)
- Almanac calendar: vertical-scroll anchoring on today + month virtualization + tap→day routing; the merged multi-stream day-feed. (todos 3, 4 data)
- Peak-overlap surfacing: `scanPeakOverlaps` per-day peak/element computation, blend + cap math, peak-def wired from ♏. (todo 6 logic)
- Cross-pane hook: ZR swipe lands on the Almanac day view at the swiped date. (todo 8)
- Pin the non-peak base-element doctrine (lean `dna.elemental.dominant`). (todo 11)

**Sonnet (rote, well-specified markup once the model exists) — cheap, parallelizable after Opus:**
- The accordion tree template (indented nested rows, badge chips) against Opus's model. (todo 1 render)
- The month-grid markup + the dot/density placeholder cells. (todos 3 render, 6 placeholder)
- The day-view rows extending the existing `upcoming` grammar (glyph · aspect · "your X" / subtitle / right time), stream-colored. (todo 4 render)
- The one-time fading row hint UI. (todo 2 hint)

**Fable (feel only, last, on settled structure) — where the pass lives or dies:**
- The **peak-overlap elemental wash**: pale-base / deep-peak translucent treatment, blend legibility, `ELEM`/`SIGN_ELEMENTS` hue tuning so fire/earth/air/water read cleanly at both pale and deep saturation with a white date on top. (todos 6, 10 treatment) — *this is the visual soul of the Almanac pass.*
- The **swipe-to-almanac feel**: drag physics, the ♐/calendar glyph surfacing from under the row, release/land animation. (todo 2 feel)
- Any AAF import wiring, if reached (protocol already names Fable master coder for that step).

**Token/time economics:** Opus is the bottleneck and the risk (decode precision, scroll + gesture disambiguation) — spend real budget there, it unblocks the rest. Sonnet handles volume-markup at low cost with zero ambiguity because Opus fixed the models. Fable is reserved for the two things only feel can settle (the wash, the swipe) — not spent on plumbing. Don't invert: Fable hand-drawing data models or Opus tuning hues both waste the expensive seat.

---

## BUILT — July 16, 2026 (Opus + Sonnet passes on `Orbo Astrolabe.dc.html`)
*Snapshots before work: `archive/Orbo Astrolabe 2026-07-16c.dc.html` (before RELEASING), `…16d.dc.html` (before Almanac). Both passes load clean, no console errors.*

**RELEASING accordion (Opus, then Sonnet polish) — todos 1, 2, 8, 9(ZR side):**
- `zrCols` (four flat columns) → **`zrRows`**: one nested L1→L4 tree flattened to indented visible rows (chevron ▸/▾, level tag, sign glyph in `ELEM` color, date). Accordion-strict — one path expanded per level; `zrSel` is the open-path, **auto-seeded to today's now-path** (`_zrNowPath`) at every sheet entry point (`openZr`, resting-lens, `openLens`, `_openSheet`). Peak-outline / `cu` / `LB` badges carry down every level.
- Gestures (pointer-based, `_zrRowDown/Move/Up` with swipe-vs-scroll disambiguation): **tap = unfold/collapse** (`_zrToggle`), **double-tap = travel the wheel** (`_zrTravel`), **swipe sideways = send to Almanac** (`_zrToAlmanac`). Travel is off single-tap entirely — fixes the "tapping the now-chapter just zooms" bug. Long-press→mark deferred (nice-to-have).
- Sonnet: ≥40px tap targets, sharper chevron/level tag; the always-on hint replaced by a **one-time fading hint** (`zrHintDismissed`, persisted; 3.6s timer + instant dismiss on first row touch).
- Decodes purely from AstroDNA (`computeLots`/`buildChapters`/`subPeriods`, peak sets from `trueAngleSigns`/`brennanAngleSigns`).

**Almanac (Opus) — todos 3, 4, 5, 6, 9(alm side), 10, 11:**
- `month` (single-month dead-end grid + docket) → **`calendar`**: a **continuous vertical scroll**, months stacked (`_almCalendarModel`, ~1 back … 13 ahead), **anchored on real today** (ref-callback scrolls the current month into view once per open; `_almScrollRefFn`/`_almTodayRefFn`). Cached by settings, never by `this.jd`, so scrubbing never rebuilds it. Saved `almForm:'month'` transparently maps to `'calendar'`.
- **Day view** (`_almDayJd`): tap a day → one civil day, time-ordered, **all fused streams** in the `upcoming` row grammar; back → calendar. It's the landing for the ZR swipe (`_zrToAlmanac` sets `_almDayJd` + travels the wheel). `upcoming` kept as-is (todo 5).
- **Peak-overlap elemental wash** (surfaces `scanPeakOverlaps`, which had no surface): every day a **pale** tint; **peak days deepen** to the saturated hue, weighted by `max_peak_lot_count` (α = min(0.5, 0.14 + count·0.09), capped). Element from AstroDNA — `SIGN_ELEMENTS` for peaking-lot signs, base tint = **`dna.elemental.dominant`** (doctrine (a), pinned), all via the wheel's `ELEM`/`ELEM_NAME` palette (`_almWash`, `_almPeakByDay`, `_elemHex`, `_rgba`). White date on top. Peak-def flows from ♏ (`state.zrPeakDef`). Stream dots retained on the cell as well.

**Left for Fable (feel):** retune the wash α-curve / hue legibility at pale + deep saturation (the current curve is a sensible Opus default, not final); the swipe-to-almanac feel (drag physics, ♐ glyph reveal, release). **Left open:** long-press→mark on ZR rows; AAF import wiring.

**Fable pass (July 17, 2026)** — snapshot `archive/Orbo Astrolabe 2026-07-17.dc.html`. Both feel items landed:
- **Wash retune:** α walks 0.16 → 0.46 across peak counts 1–5 (each step ~0.075 — 2 vs 5 lots clearly apart, capped below drowning a white date); mixed-element peak days blend the top two elements as a soft 160° gradient; base days at α 0.07. Today's marker rewired for air-peak collisions: solid gold ring + outer glow + warm-white date (`#fff7e8`); dates carry a faint dark text-shadow so white stays crisp on deep cells; count ≥4 days get a subtle inset shadow for extra weight.
- **Swipe feel:** each ZR row now sits on a hidden gold ♐ under-layer; during a horizontal drag the row tracks the finger (clamped ±96px, transition off) while the under-layer fades in toward the 44px commit threshold and brightens past it; release under threshold springs back (0.22s spring curve), committed release slides the row out along the drag (0.18s ease-in) and hands off to the Almanac day view ~160ms later. `pointercancel` wired to snap back. Detection thresholds and tap/double-tap logic untouched — presentation only.
