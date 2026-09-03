# Astrolabe and Lunar Pane — Act I

Branch: `feature/astrolabe-lunar-pane-swift-2026-09-03`, based on assembled `525ec67`.

## Authorized scope

Transcribe the prototype Aegis, Big Three and the first Lunar Pane FACT course into Swift. Apollo owns the Aegis; Artemis receives her chart subject from Apollo; Iris displays their standard ports. Hestia's kept Tapestry is the natal source. Horae reads the one mounted OrboSpine for the displayed sky. Hecate casts the local ASC from that same Terra sample and the supplied Topos. Themis and Rhea supply whole-sign and condition answers. Aether supplies authored environmental matter.

The Big Three, date, and live status are central instrument readouts. Natal selection must never substitute natal positions into the sky header. The native chart carries exact placements, motion, houses and conditions from the Tapestry unchanged. The natal list, selected detail, and wheel share that chart.

Act I includes the two seats, horizon-oriented drawing when a place is supplied, select-to-read, sky/natal reading selection, the prototype palette and curved Pane anatomy. The current birthplace supplies the displayed local horizon and is named on screen. Before a place exists no ASC or houses are manufactured. Existing birth entry, text/3D, and diagnostics remain available. The pre-port app is preserved in `native/OrboCore/Obsolete/AppHarness/OrboAssembledApp.swift`.

The wheel's house band follows the live ASC, as the prototype's `skin.houseNums` renderer does. The natal Pane retains natal whole-sign houses. The wheel's Moon uses the Sun's screen bearing; the header disc retains the prototype's waxing/waning convention. Both receive the same Ring separation from Apollo.

## Transcription sources

The original `Orbo Astrolabe.dc.html` remains unchanged. Its `_moonFace`, `_sheetDataSky`, `_chartFactRows`, sign/house drawing, and recessed natal track supplied the reference behavior. The existing `orbo-logo.png` and `orbo.png` are copied unchanged into the Iris resource bundle. Aether supplies the authored background palette and decorative stars, which are presentation matter rather than astronomical measurements.

| Native owner | Act I responsibility |
| --- | --- |
| Apollo | Hold the Horae cross-section; prepare sky and kept natal placements; signal the Aegis to Iris |
| Hecate, Themis, Rhea, Oceanus | Supply the existing ASC/Sect, houses, condition, and Ring-separation answers |
| Hestia | Supply the canonical kept Tapestry and its exact natal positions and testimony |
| Artemis | Receive Apollo's selected chart/body and signal the FACT reading to Iris |
| Aether / Iris | Supply environment matter / render geometry, glyphs, and controls |

## Subsequent acts

Planet scrubbing must be decoupled from fingertip longitude: gesture displacement drives temporal travel and displayed body positions return from the real Timespine. Gesture gearing, playback, full Tabula operation, aspect web/magnetism, and Pane spring/lens behavior belong to Act II. Other reading templates and technique/corpus connections belong to Act III. No MC, auxiliary bodies, event answers, or prose are invented for a missing native source.

The first lunar disc transcribes the prototype's Sun/Moon longitude-separation display. It is not an additional three-dimensional lunar astronomy model. Iris's old 3D palette remains available; the prototype classic palette is separate presentation material.

## Run and inspect

Open `native/Orbo.xcodeproj` on this branch, choose the **Orbo** scheme, and run. After the real Spine loads, **Astrolabe** shows the sky. Open **Hearth**, edit or retain Ean's birth inputs, and choose **Begin**. **See my natal chart** opens the kept natal FACT reading on the Astrolabe. Tap a placement or row to inspect it; **NATAL** and **THE SKY** choose the chart being read. The down chevron lowers the Pane. The time/live control returns the instrument to the current sky. The civic clock displays the device's timezone, while the named birthplace supplies this first pass's local horizon.

The **Text** and **Inspect** tabs retain the existing alternate readout and diagnostics. The iOS 26 guard remains confined to the older optional 3D view. Profiles remain session-scoped as in the assembled app; this pass does not add persistence or a full 360-degree Tapestry browser.

## Proof

Tests exercise Ean's real night chart and two additional real births, exact Tapestry-to-pane values, unchanged natal data across a changing sky, the local ASC cast from the same Horae frame, refusal of mixed moments, and absence of an invented horizon. Geometry proof checks horizon orientation without changing coordinates.

The dedicated workflow runs the accumulated package and Xcode suites, builds Orbo and OrboLab, and captures the real Aegis, natal Pane and selected Sun in the simulator. Its launch argument drives the production selection callbacks with real sealed Spine data; it is not a synthetic runtime.

Act I is verified by [run 33733075809](https://github.com/huntarfischer/orbobuilder/actions/runs/33733075809): 941 package tests and 941 Xcode tests (858 Core + 83 Iris), zero failures; both app targets built and launched; all five simulator captures inspected. The live timer follows scene/tab activation, and the standalone proof observes a later real Horae frame after four seconds while the natal chart remains unchanged. See `specs/gates/2026-09-03-Astrolabe-Act-I.md` for the exact tested commit, evidence and practical limits. Acts II and III are not promoted by this gate.
