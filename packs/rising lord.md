{\rtf1\ansi\ansicpg1252\cocoartf2822
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fnil\fcharset0 Monaco;}
{\colortbl;\red255\green255\blue255;\red70\green137\blue204;\red23\green23\blue23;\red202\green202\blue202;
\red99\green159\blue215;\red194\green126\blue101;}
{\*\expandedcolortbl;;\cssrgb\c33725\c61176\c83922;\cssrgb\c11765\c11765\c11765;\cssrgb\c83137\c83137\c83137;
\cssrgb\c45490\c69020\c87451;\cssrgb\c80784\c56863\c47059;}
\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\deftab720
\pard\pardeftab720\partightenfactor0

\f0\fs24 \cf2 \cb3 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec2 # Spec \'97 the Rising Lord (Ascendant Lord of the moment)\cf4 \cb1 \strokec4 \
\
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec4 *Draft for review, not a build order. Every "what exists" claim is grounded in the current `Orbo Astrolabe.dc.html` / `rulers.js` / `astrodna.js`. Name is unsettled: "Rising Lord" / "Ascendant Lord" / "Lord Ascending" \'97 pick before code.*\cf4 \cb1 \strokec4 \
\
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 ---\cf4 \cb1 \strokec4 \
\
\cf2 \cb3 \strokec2 ## What it is\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec4 The lord of the sign **rising right now**, at the here-&-now horizon, and its **state** at that instant. As the ascendant crosses each 30\'b0 boundary the lord hands off (~12\'d7/day). This is the fast hand of the disposition layer \'97 the natal/local cousin of the composite-frame cASC handoff the doctrine already reads live.\cf4 \cb1 \strokec4 \
\
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec4 **Not planetary hours.** No equal/seasonal twelfths. The handoff moments are the **oblique ascension** of each sign boundary \'97 the exact thing an astrolabe plate computes.\cf4 \cb1 \strokec4 \
\
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 ## The one thing to get right (your correction, 07-18)\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec4 **Never merge consecutive same-lord signs.** Saturn rules both Capricorn and Aquarius, but they are two different windows because the whole-sign house framework rotates with the ascendant:\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 - \cf4 \strokec4 Saturn in Aries, **Capricorn** rising \uc0\u8594  Saturn in the **4th**.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf4 \strokec4 Saturn in Aries, **Aquarius** rising \uc0\u8594  Saturn in the **3rd**.\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec4 Same planet, different house, different area of life. The window's whole-sign house is computed **relative to that window's rising sign**, recomputed each handoff. Merging would erase the only distinction the feature exists to show. So: **12 windows a day, one per rising sign, even when the lord repeats.**\cf4 \cb1 \strokec4 \
\
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 ## Grain (settled)\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec4 Sign-lord only for now. (Bounds/terms lord is a possible later "deep" toggle \'97 not this pass.)\cf4 \cb1 \strokec4 \
\
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 ---\cf4 \cb1 \strokec4 \
\
\cf2 \cb3 \strokec2 ## What already exists \'97 consume, do not rebuild\cf4 \cb1 \strokec4 \
\
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec4 **Almanac = fused-stream engine** (\cf5 \strokec5 `Orbo Astrolabe.dc.html`\cf4 \strokec4 ):\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 - \cf5 \strokec5 `state.fused`\cf4 \strokec4  \'97 array of stream ids currently on: \cf5 \strokec5 `transits`\cf4 \strokec4 , \cf5 \strokec5 `zr`\cf4 \strokec4 , \cf5 \strokec5 `cross`\cf4 \strokec4 , \cf5 \strokec5 `beads`\cf4 \strokec4 .\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf5 \strokec5 `_almEvents(a,b)`\cf4 \strokec4  \'97 merges + sorts every fused stream's events for the window; cached by hour-rounded window + config.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf4 \strokec4 Per-stream builders \cf5 \strokec5 `_almTx`\cf4 \strokec4 , \cf5 \strokec5 `_almZrStarts`\cf4 \strokec4 , \cf5 \strokec5 `_almCross`\cf4 \strokec4 , \cf5 \strokec5 `_almBeads`\cf4 \strokec4  \'97 each returns event objects shaped \cf5 \strokec5 `\{ jd, kind, col, label, sub, lb? \}`\cf4 \strokec4 .\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf5 \strokec5 `almStreams`\cf4 \strokec4  (\uc0\u9808  console) \'97 one row per fusible stream: \cf5 \strokec5 `\{ id, name, dot, ok, sub, chips \}`\cf4 \strokec4  + a fuse toggle (\cf5 \strokec5 `_toggleFuse(id)`\cf4 \strokec4 ).\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf4 \strokec4 Read-forms: \cf5 \strokec5 `almUpcoming`\cf4 \strokec4  (agenda), \cf5 \strokec5 `almCalendar`\cf4 \strokec4  (month grid), day view (\cf5 \strokec5 `_almDayJd`\cf4 \strokec4 ). \cf5 \strokec5 `evRow(ev)`\cf4 \strokec4  renders a row from an event, already surfaces \cf5 \strokec5 `col`\cf4 \strokec4 , \cf5 \strokec5 `label`\cf4 \strokec4 , \cf5 \strokec5 `sub`\cf4 \strokec4 , \cf5 \strokec5 `time`\cf4 \strokec4 , and an \cf5 \strokec5 `lb`\cf4 \strokec4 \uc0\u8594 badge.\cf4 \cb1 \strokec4 \
\
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec4 **Color law** (two coexist, neither is condition-based \'97 this corrects my earlier "color by condition"):\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 - \cf4 \strokec4 Per-stream accent: transits \cf5 \strokec5 `#4da4d9`\cf4 \strokec4 , zr \cf5 \strokec5 `#e8ab41`\cf4 \strokec4 , cross \cf5 \strokec5 `#dd8f78`\cf4 \strokec4 , beads \cf5 \strokec5 `#beb8e2`\cf4 \strokec4 .\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf4 \strokec4 Per-element for sign events: the ZR detail colors periods by triplicity via \cf5 \strokec5 `this.ELEM[signIndex % 4]`\cf4 \strokec4  (fire/earth/air/water) \'97 this is what the iCal screenshot shows.\cf4 \cb1 \strokec4 \
\
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec4 **Engine helpers already available:**\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 - \cf5 \strokec5 `rulers.lordOf(lonDeg)`\cf4 \strokec4  \uc0\u8594  \cf5 \strokec5 `\{ sign, signIndex, degreeInSign, ruler, exalted, exaltDegree \}`\cf4 \strokec4 . Domicile + exaltation only.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf5 \strokec5 `astrodna.houseOf(signIdx, ascSignIdx)`\cf4 \strokec4  \'97 whole-sign house of a sign given the ascendant sign. Exactly the rotating-house math above.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf5 \strokec5 `ephem.angles(jd, lat, lon).asc`\cf4 \strokec4  \'97 the ascendant longitude at a jd/place.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf5 \strokec5 `ephem.bodyLon(jd, name)`\cf4 \strokec4  \'97 single-body longitude (fast); use for the lord's position + a finite-difference speed for retrograde.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf4 \strokec4 Location: \cf5 \strokec5 `this.lat`\cf4 \strokec4  / \cf5 \strokec5 `this.lng`\cf4 \strokec4 , the "Here & now" seat, \cf5 \strokec5 `state.locLabel/locPlace`\cf4 \strokec4 . The here-&-now horizon is already modeled.\cf4 \cb1 \strokec4 \
\
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec4 **ICS export** (\cf5 \strokec5 `_exportAlmanacICS`\cf4 \strokec4 ): writes **one flat VCALENDAR** of the fused window \'97 1h events, \cf5 \strokec5 `SUMMARY = KIND + ': ' + label`\cf4 \strokec4 , **no `CATEGORIES`, no `X-WR-CALNAME`**. Nothing is independently toggleable inside a calendar app today.\cf4 \cb1 \strokec4 \
\
\cf4 \cb3 \strokec4 **Gaps in what exists (small build, flag them):**\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 - \cf5 \strokec5 `rulers.js`\cf4 \strokec4  has domicile + exaltation but **no detriment/fall** \'97 condition needs them (planet in sign opposite its domicile = detriment; opposite its exaltation = fall). Add a \cf5 \strokec5 `dignityOf(planet, lonDeg)`\cf4 \strokec4  helper to \cf5 \strokec5 `rulers.js`\cf4 \strokec4  rather than deriving locally.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf4 \strokec4 No ascendant-boundary root-finder yet.\cf4 \cb1 \strokec4 \
\
\cf2 \cb3 \strokec2 ---\cf4 \cb1 \strokec4 \
\
\cf2 \cb3 \strokec2 ## The engine to build\cf4 \cb1 \strokec4 \
\
\pard\pardeftab720\partightenfactor0
\cf5 \cb3 \strokec5 `_risingWindows(a, b, lat, lon)`\cf4 \strokec4  \uc0\u8594  ordered array, one entry per ascendant sign-crossing in \cf5 \strokec5 `(a,b]`\cf4 \strokec4 , each:\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf6 \cb3 \strokec6 ```\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf5 \cb3 \strokec5 \{ jd,                 // the crossing minute (oblique ascension of the boundary)\cf4 \cb1 \strokec4 \
\cf5 \cb3 \strokec5   risingSign,         // sign index now on the ascendant\cf4 \cb1 \strokec4 \
\cf5 \cb3 \strokec5   lord,               // rulers.DOMICILE[risingSign]\cf4 \cb1 \strokec4 \
\cf5 \cb3 \strokec5   lordSign,           // lord's own sign at jd (via bodyLon)\cf4 \cb1 \strokec4 \
\cf5 \cb3 \strokec5   lordHouse,          // astrodna.houseOf(lordSign, risingSign)  \uc0\u8592  rotates per window\cf4 \cb1 \strokec4 \
\cf5 \cb3 \strokec5   condition \}         // \{ retro, dignity \}  dignity \uc0\u8712  domicile|exalt|detriment|fall|peregrine\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf6 \cb3 \strokec6 ```\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 - \cf4 \strokec4 **Boundary find:** bisect \cf5 \strokec5 `asc(jd) \uc0\u8722  k\'b730`\cf4 \strokec4  (unwrap the 0/360 seam). Ascendant advances ~one full turn per day but its rate varies hugely by sign \'97 that unevenness is the feature; render true widths.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf4 \strokec4 **Live fast-hand:** computed per window, **never materialized on the timespine** \'97 same law that refuses the Moon and cASC handoffs.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf4 \strokec4 **High latitude:** signs of short ascension can rise in minutes; some may not rise at all above ~66\'b0. Degrade gracefully (skip non-rising signs, don't crash the finder).\cf4 \cb1 \strokec4 \
\
\cf2 \cb3 \strokec2 ## The two surfaces (one engine)\cf4 \cb1 \strokec4 \
\
\cf2 \cb3 \strokec2 1. \cf4 \strokec4 **Timing tab \'97 standalone.** The primary home: scrub a day and see its rising-lord windows on their own, play with it. \cf5 \strokec5 `_risingWindows`\cf4 \strokec4  renders directly here. *(Confirm exact host sheet \'97 the "Timing" tab is the `releasing` panel; tell me whether this is a new sub-view there or its own sheet.)*\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 2. \cf4 \strokec4 **Almanac \'97 fusible.** \cf5 \strokec5 `_almRisingLord(a,b)`\cf4 \strokec4  wraps the **same** \cf5 \strokec5 `_risingWindows`\cf4 \strokec4  call into \cf5 \strokec5 `\{ jd, kind:'rising', col, label, sub \}`\cf4 \strokec4 , registered in \cf5 \strokec5 `_almEvents`\cf4 \strokec4 , plus one \cf5 \strokec5 `almStreams`\cf4 \strokec4  row (\cf5 \strokec5 `\{ id:'rising', dot, ok: hasLoc \}`\cf4 \strokec4 ). Fusing drops the minute-marks in among transits/ZR.\cf4 \cb1 \strokec4 \
\
\cf2 \cb3 \strokec2 ## Display (settled)\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf4 \strokec4 **At a glance:** the day as a list of **sign-change minutes** \'97 \cf5 \strokec5 `7:35 \uc0\u9792  Taurus`\cf4 \strokec4  \'b7 \cf5 \strokec5 `9:48 \uc0\u9791  Gemini`\cf4 \strokec4  \'b7 \'85 Crossing time + rising sign + lord glyph. Nothing else.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf4 \strokec4 **On tap:** expand to full state \'97 lord's sign, rotating whole-sign house, condition, and the areas of life the rising sign governs. (App's existing glance-row + tap-to-open grammar.)\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf4 \strokec4 **Color:** element color on the rising sign (\cf5 \strokec5 `this.ELEM[risingSign % 4]`\cf4 \strokec4 ), matching ZR.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf4 \strokec4 **Condition:** a **badge** (mirrors the ZR \cf5 \strokec5 `LB`\cf4 \strokec4  badge) \'97 \cf5 \strokec5 `Rx`\cf4 \strokec4 , \cf5 \strokec5 `domicile`\cf4 \strokec4 , \cf5 \strokec5 `fall`\cf4 \strokec4 , etc. Not a recolor.\cf4 \cb1 \strokec4 \
\
\cf2 \cb3 \strokec2 ## Export\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec4 Rising Lord exports as **its own named calendar**, so it's independently toggleable in Apple/Google Calendar:\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 - \cf4 \strokec4 separate \cf5 \strokec5 `VCALENDAR`\cf4 \strokec4  with \cf5 \strokec5 `X-WR-CALNAME:<name> \'b7 <locus>`\cf4 \strokec4  (locus baked in \'97 these times are horizon-dependent),\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf5 \strokec5 `CATEGORIES:<name>`\cf4 \strokec4  per VEVENT,\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf4 \strokec4 bounded date-range download (an .ics is frozen; no live webcal without a server \'97 name the limit).\cf4 \cb1 \strokec4 \
\
\cf2 \cb3 \strokec2 ---\cf4 \cb1 \strokec4 \
\
\cf2 \cb3 \strokec2 ## Still open (your call before I code)\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 1. \cf4 \strokec4 **The name.**\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 2. \cf4 \strokec4 **Timing host** \'97 new sub-view under the \cf5 \strokec5 `releasing`\cf4 \strokec4 /Timing tab, or its own sheet?\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 3. \cf4 \strokec4 **Condition scope** \'97 dignity + retrograde only, or also sun-relationship (combust/cazimi) now? (I'd hold combustion for later.)\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 4. \cf4 \strokec4 **Peregrine** \'97 show "peregrine" when the lord has no essential dignity, or leave the badge blank?\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 5. \cf4 \strokec4 **Export trigger** \'97 from Timing, from the almanac console, or both?\cf4 \cb1 \strokec4 \
\
\cf2 \cb3 \strokec2 ## Verification\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf4 \strokec4 Feed a known chart/place: confirm ~12 windows/day, unequal widths, at plausible ascendant-crossing minutes.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf4 \strokec4 Saturn-in-Aries case: Capricorn window shows 4th house, Aquarius window shows 3rd \'97 **two separate rows**, not one.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf4 \strokec4 Retrograde/dignity badge matches the lord's live state at the crossing jd.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf4 \strokec4 Fused into the almanac, minute-marks interleave correctly with transits/ZR in the day view.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 - \cf4 \strokec4 Export opens as its own toggleable calendar with the locus in its name.\cf4 \cb1 \strokec4 \
\
}