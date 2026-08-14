# Orbo — the pack economy

*Direction captured 2026-07-28 from conversation. Not a build spec: no code changes yet, and
**Phase 2 is deliberately unaffected** (see §6). A thing to react to and refine.*

---

## 1 · The boundary: tradition is free, invention is Pro

The first attempt at a paid boundary was *prose is sellable, computation isn't* — a corollary of the
byline law (§8 of the Depth Manifest: attribute text, never numbers). It held for readings but could
not place the lenses: electional windows and the synastry grid are engine labor, not prose, yet they
are the most "professional" surfaces in the app.

**The sharper rule:** you cannot sell the tradition, but you can sell your own invention.

| Free, always | Pro |
|---|---|
| the instrument — plate, rete, the whole sky | **composite chronology** (the native's own invention) |
| classical technique — ZR, profections, electional, synastry, lots | future original lenses |
| doctrine presets (how your instrument is cut is a maker's choice) | |
| the journal / memory | |
| one default interpretation pack | additional packs (per-author, or all of them with Pro) |

Electional is Dorotheus and Lilly — available in any app, so it stays free. Composite chronology exists
nowhere else. That line is explainable to a user in one sentence, which is the test it has to pass.

**Depth is NOT the paywall.** L1/L2/L3 is inference distance for the *reader*, seeded from a
self-description question in orientation. Making it the price tier would turn that question into a
pricing funnel and turn Orbo's honest gated-pointer ("that sits deeper than your current reading")
into an upsell prompt. It would also charge for the engine's own output: L3 is where lineage labels
live, and a lineage cites a *technique*, not an author — nobody wrote the ZR period table, `zr.js`
computes it. Paywalling L3 pays the house for the tradition's work and the authors for nothing.

## 2 · What a pack is

A **voice**. One author's words about placements and vocabulary. Sold per author (~$0.99) or bundled
with Pro.

The architecture already supports this: `PACK_REGISTRY` + `loadPack(id)`, and attribution is
single-sourced per pack (`pack.attribution`, `pack.attributionUrl`) — so each pack is already a
discrete, countable, attributable unit, which is exactly what per-author revenue share needs. Adding
`price` / `license` to the manifest is trivial.

Free tier without any pack is honest rather than crippled: **the instrument tells you what is; a voice
tells you what it means.** That is the sun/moon law expressed as a business model.

**Consequence, not yet absorbed:** nobody has ever written interpretations for composite chronology,
because it did not exist until the native invented it. So *the native is the first pack author*, and
the format must hold their writing beside DPA's on equal terms. Good forcing function — any weakness
in the format gets felt from the inside first.

## 3 · Multiple voices at once — the feature

Packs are **toggles, not a radio.** Both on. Two authors disagreeing is the thing no single-author app
can offer, and the move that makes it work already exists: when DPA teaches modern rulers and the plate
is cut traditional, Orbo *names the source* rather than picking a side. That scales — "Dark Pixie reads
it this way; ⟨other⟩ reads it that way" — and it is an argument for owning several.

**The byline is the switcher.** Not a bare swipe. The byline already sits at the foot of every reading
and already names whose words those are; making it the control means you cannot read a passage without
seeing the source, and cannot switch without watching the credit change. Pips beside it show *1 of 2*.
A bare gesture is invisible to someone who owns one pack — it does nothing until you buy, so nobody
discovers it — whereas a byline that grows a second pip *is* the merchandising, honestly done.
(Check that horizontal is actually free in the pane before committing: the sub-arc pills and the
register switcher may already claim it.)

## 4 · Three things that will bite

1. **Coverage is ragged.** DPA has 876 placement readings; a releasing-focused author would be deep on
   ZR and silent on Chiron. Build the stack **per reading, not globally** — only packs holding an entry
   for *this* body get a pip. Otherwise you swipe into nothing, which is worse than offering no swipe.
2. **Depth × pack can produce paid silence.** Every entry carries its own depth. An author writing
   mostly at L3 means a plain-depth reader who *paid* sees nothing from them. Free content going quiet
   is honest; purchased content going quiet feels broken. Orbo likely has to say "⟨author⟩ writes about
   this deeper than your current reading" rather than omitting them.
3. **Order needs an owner.** `explainSearch` iterates one pack today. Multi-pack needs a first voice —
   user-orderable in Orbo's menu (packs are voices; you choose whose you hear first), DPA default
   because it is the beginner voice.

## 5 · Real-world dependency

The format presumes third-party authors. A named living astrologer's pack is a licensing conversation,
not an implementation detail — worth having early, because it shapes the revenue-share terms the
manifest fields need to encode.

## 6 · Why Phase 2 does not change

None of this alters the depth ladder. Depth is not the paywall, so the contract, the co-rulership
split, the lineage rendering and the manifest application are all unaffected. **Do not let a future
monetization idea leak into a depth refactor** — the same reason two depth contracts would be worse
than none.

The two places that would eventually become multi-pack are `_packCite()` (returns one cite) and the
byline (renders as static text). Both are single-purpose and cheap to widen later. Note them; do not
build for them yet.
