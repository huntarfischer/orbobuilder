# Spec — the Field Journal as a memory (♒) surface, with photo recall

*Draft for review, not a build order. Grounds against current `Orbo Astrolabe.dc.html`, `timespine.js`, `astrodna.js`, `ephem.js`. Two directions of one loop: sky → photo ("On this transit") and photo → sky ("what was the sky when I shot this").*

---

## The frame
The Field Journal is Orbo's **memory (♒)**: authored meaning pinned to events. Photos extend it — a photo carries **EXIF: a timestamp (`jd`) and often a geotag (horizon)**, which is exactly what astroDNA needs to decode the sky at that moment. So a photo is an **involuntary journal entry, logged automatically.** Two feeds into one ♒ store, keyed identically (event identity = `kind|bodies|angle|jd`).

Read-only, opt-in, **on-device.** Nothing about the instrument (the sun) changes; this is entirely moon → memory.

## Hard law — state before any code
1. **Local-only. Photos never leave the device.** EXIF is read in-memory from a user-picked folder/album (File System Access API, or `<input type=file multiple accept=image/*>` in the prototype). The pixels are never uploaded, never persisted by Orbo.
2. **Opt-in, revocable.** No access until the user grants it; a single control revokes and purges all derived data.
3. **Only derived keys persist — never images.** What we store is `{ eventKey, photoRef, jd, place }`, where `photoRef` is a user-scoped handle (filename / FS handle id), **not** image bytes. On reload we re-read from the granted source; if access is gone, entries show as "photo unavailable," never a broken store.
4. **Derivation is transparent.** The user can see, per photo, exactly what was read (timestamp, geotag) and what was decoded (the transit), and delete any of it.

---

## What already exists — consume, don't rebuild

- **Field Journal store** — the ♒ memory keyed to event identity (the `+` on almanac events; `localStorage 'orbo.astrolabe.back'` region migrated in `_back` init). Journal entries already hang off `eventKey`.
- **timespine** — every ephemeris-expensive event across the life materialized, each with a stable identity `kind|bodies|angle|jd`. **Past occurrences of any transit signature are already computed.** This is the backbone of "On this transit."
- **astroDNA `_natal()` / decode** — genome → positions at any jd; `houseOf`, `lordOf`, aspect math.
- **`ephem.positions(jd)` / `bodyLon(jd,name)` / `angles(jd,lat,lon)`** — sky at an arbitrary jd/place. This is what a single photo's EXIF resolves through.
- **transits engine** — contact detection (which natal points a moment aspects, application/separation).
- **Location model** — `this.lat/this.lng`, "Here & now" seat, `state.locLabel/locPlace` for the geotag fallback.

**Gaps (small builds, flag them):**
- **EXIF reader.** No dependency yet. Need timestamp (`DateTimeOriginal`) + GPS (`GPSLatitude/Longitude`) parse. A tiny local parser or one vendored lib — must run fully client-side.
- **Photo → event-key resolver** and its inverse **signature → past-windows query** (below).
- **The "live transit signature" abstraction** — a canonical string for "the transit(s) active now" so photo windows can be matched to it.

---

## Data model

```
JournalEntry {
  eventKey,            // kind|bodies|angle|jd  — shared with authored entries
  source: 'authored' | 'photo',
  note?,               // authored text (existing behavior)
  photo? {
    ref,               // FS handle id / filename — NOT bytes
    exifJd,            // DateTimeOriginal → jd
    exifPlace?,        // {lat,lon} from GPS, or null
    placeSource: 'exif' | 'fallback',
    decoded {          // the sky at exifJd/exifPlace, cached so we don't re-decode
      transits: [signature…],   // canonical transit strings active at exifJd
      risingSign, risingLord,   // the horizon at that instant (if place known)
      moonPhase, ...            // whatever the read-form shows
    }
  }
}
```
- Authored and photo entries coexist on the same `eventKey`, so "the day Saturn crossed my Venus" can hold both a note *and* three photos.
- `decoded` is cached derived data — invalidated only if the genome changes.

## The two directions (one loop)

### A. Photo → sky ("populate the exact transit for this photo")
User pulls in a photo → Orbo reads EXIF → decodes.
1. Read `DateTimeOriginal` → `exifJd`. Read GPS → `exifPlace`, else `placeSource:'fallback'` (genome locus; time-only decode, no rising-lord).
2. `ephem.positions(exifJd)` + transits engine against the genome → the **active transit signature(s)** at that moment, the rising lord (if placed), moon phase, ZR period.
3. Snap to the nearest **timespine event** whose window contains `exifJd` → that's the `eventKey` the photo pins to. (A photo mid-transit binds to the transit's spine row, not to its own loose jd — so it joins the same key as other memories of that transit.)
4. Present: "This photo was taken during **Tr. Saturn □ natal Venus**, Scorpio rising, waning Moon." Save as a `photo` JournalEntry. **This is the manual, precise direction** — the user asserts a photo, gets its exact sky.

### B. Sky → photo ("On this transit" — the nostalgia feed)
Orbo seeks photos from *similar* past transits.
1. Take the **current** (or any scrubbed) transit signature — e.g. `Tr. Saturn □ natal Venus`.
2. Query the timespine for **all past occurrences of that same signature** across the life → a set of `[start,end]` windows (the spine already has these).
3. Match granted-album photo timestamps that fall in those windows.
4. Surface them: "Last time Saturn squared your Venus — Nov 2019 — you were photographing this." **This is the automatic, associative direction** — Orbo brings the past forward unprompted.

**Similarity grain (decide):** exact signature (same bodies + same angle) is the tight default. Looser tiers — same transiting body to same natal point at *any* angle, or same natal point touched by *any* transit — widen the net for richer nostalgia. Recommend: exact by default, "widen" control for more.

**Density law:** decode **on query, lazily.** Never scan 20k photos up front. Direction B pulls only photos whose timestamp lands in a matched window; Direction A decodes only the one photo pulled in. EXIF timestamp read is cheap; full decode happens only for photos that survive the window filter.

## EXIF hygiene (real friction)
- **Screenshots / saved memes / downloads** carry timestamps that aren't *your* moments and pollute the feed. Filter: prefer photos with a **camera make/model** EXIF tag or a **geotag**; offer a "camera photos only" toggle. Let the user cull a surfaced set.
- **No timestamp** → cannot place on the spine; excluded from both directions (show why).
- **No geotag** → time-only decode; transit resolves, rising-lord does not. Mark the entry `placeSource:'fallback'`.
- **Timezone/UTC:** EXIF time is usually local-without-zone; combine with the geotag (or fallback locus) to resolve to UTC → jd. Ambiguous-zone photos: note the uncertainty, don't fake precision.

## Surfaces
- **The `+` on every almanac event** (existing) gains a photo affordance next to the note: authored note *and* "attach / find photos." Same control, two feeds.
- **"On this transit" strip** — in the lunar pane / reading surface, when a transit is live or scrubbed, a quiet row of past-occurrence photos. Nostalgia, not a demand for engagement.
- **Photo drop** anywhere in the reading surface → Direction A → shows the transit → offers to save.
- Photo entries render with their decoded sky as caption; tapping a past-occurrence photo travels the almanac to that date (existing tap-to-travel).

## GEIST relationship
This is the **single-user stone** of GEIST's temporal correlation — it makes "resonance across time" *felt* by showing you your own life against the sky. The multi-user extension (two albums decoded to the same spine = synchronic synastry with photographic evidence) is the network tier and explicitly **out of scope here.**

## Still open (your call)
1. **Similarity grain default** — exact signature vs. widen tiers.
2. **Which transits count** — outer-planet slow transits (rare, resonant, few photos) vs. also fast Moon transits (daily, thousands of matches — probably too noisy for the nostalgia feed; maybe elections-only).
3. **Album source in the prototype** — one-shot file picker (simplest, re-pick each session) vs. persisted FS Access handle (smoother, more permission surface).
4. **Fallback place** — genome birthplace vs. current "Here & now" locus for geotag-less photos.
5. **Photo entry key** — snap to the spine event (recommended, groups memories) vs. keep the photo's own loose jd.

## Verification
- Opt-in gate blocks all reads until granted; revoke purges derived entries; reload with access gone shows "unavailable," never a crash or an upload.
- A geotagged camera photo: EXIF jd + place decode to the correct historical transit + rising lord; verify against a hand-run positions(jd).
- "On this transit" for a slow outer transit returns only photos inside the spine's past-occurrence windows for that exact signature.
- A screenshot with a bogus timestamp is filtered out (no camera tag / no geotag).
- A geotag-less photo decodes time-only, marked `fallback`, no rising lord.
- Confirm no image bytes appear in localStorage or any network request.
