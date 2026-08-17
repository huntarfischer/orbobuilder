#!/usr/bin/env python3
"""Build explicit retrograde celestial-time passage tables for the Saturn vertebra.

The table is framed in celestial time. A retrograde passage is a segment in which a body's
celestial-time degree sequence decreases as civic UT increases. The exact turn boundaries come
from StationTablePOC. Whole-degree retrograde crossings come from the already-generated 1-degree
Timespine records, so assembly itself does not query Swiss Ephemeris.
"""

from __future__ import annotations

import argparse
import csv
import json
import struct
from pathlib import Path

BODIES = ["Sun", "Moon", "Mercury", "Venus", "Mars", "Jupiter", "Saturn"]
SATURN_START_JD = 2439553.3967229538
SATURN_END_JD = 2450180.8673149766
VERTEBRA_SECONDS = int(round((SATURN_END_JD - SATURN_START_JD) * 86400.0))


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--input-dir", required=True, help="low-1deg directory containing *.relative.bin")
    p.add_argument("--station-table", required=True)
    p.add_argument("--output-dir", required=True)
    return p.parse_args()


def read_relative(path: Path) -> list[tuple[int, int]]:
    data = path.read_bytes()
    if len(data) % 6:
        raise ValueError(f"{path} length is not a multiple of 6 bytes")
    return [struct.unpack_from("<IH", data, offset) for offset in range(0, len(data), 6)]


def decreasing_distance(start_deg: float, end_deg: float) -> float:
    distance = (start_deg - end_deg) % 360.0
    return 0.0 if abs(distance - 360.0) < 1e-12 else distance


def main() -> None:
    args = parse_args()
    input_dir = Path(args.input_dir)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    station = json.loads(Path(args.station_table).read_text())
    boundaries_by_body: dict[str, dict[str, dict]] = {body: {} for body in BODIES}
    for row in station["vertebraBoundaries"]:
        boundaries_by_body[row["body"]][row["boundary"]] = row

    turns_by_body: dict[str, list[dict]] = {body: [] for body in BODIES}
    for row in station["celestialTurns"]:
        turns_by_body[row["body"]].append(row)
    for rows in turns_by_body.values():
        rows.sort(key=lambda x: x["civicTime"]["utOffsetSeconds"])

    all_passages: list[dict] = []
    all_degree_rows: list[dict] = []
    by_body: dict[str, dict] = {}

    for body in BODIES:
        records = read_relative(input_dir / f"{body}.relative.bin")
        start = boundaries_by_body[body]["start"]
        end = boundaries_by_body[body]["end"]
        turns = turns_by_body[body]

        segments: list[dict] = []
        segment_start_offset = 0
        segment_start_degree = start["celestialTime"]["longitudeDegrees"]
        current_sequence = start["sequence"]
        segment_start_source = "vertebra_start"

        for turn in turns:
            turn_offset = turn["civicTime"]["utOffsetSeconds"]
            turn_degree = turn["celestialTime"]["longitudeDegrees"]
            segments.append({
                "startOffsetSeconds": segment_start_offset,
                "endOffsetSeconds": turn_offset,
                "startCelestialTimeDegrees": segment_start_degree,
                "endCelestialTimeDegrees": turn_degree,
                "sequence": current_sequence,
                "startSource": segment_start_source,
                "endSource": "celestial_turn",
            })
            segment_start_offset = turn_offset
            segment_start_degree = turn_degree
            current_sequence = turn["sequenceAfter"]
            segment_start_source = "celestial_turn"

        segments.append({
            "startOffsetSeconds": segment_start_offset,
            "endOffsetSeconds": VERTEBRA_SECONDS,
            "startCelestialTimeDegrees": segment_start_degree,
            "endCelestialTimeDegrees": end["celestialTime"]["longitudeDegrees"],
            "sequence": current_sequence,
            "startSource": segment_start_source,
            "endSource": "vertebra_end",
        })

        retro_segments = [s for s in segments if s["sequence"] == "decreasing"]
        retro_degree_count = 0
        first_record_index = 0

        for passage_index, seg in enumerate(retro_segments, start=1):
            while first_record_index < len(records) and records[first_record_index][0] < seg["startOffsetSeconds"]:
                first_record_index += 1
            i = first_record_index
            degree_rows = []
            while i < len(records) and records[i][0] <= seg["endOffsetSeconds"]:
                offset_seconds, degree = records[i]
                degree_rows.append({
                    "body": body,
                    "retrogradePassage": passage_index,
                    "celestialTimeWholeDegree": degree,
                    "civicTimeOffsetSeconds": offset_seconds,
                    "civicTimeJulianDayUT": SATURN_START_JD + offset_seconds / 86400.0,
                })
                i += 1
            first_record_index = i
            retro_degree_count += len(degree_rows)
            all_degree_rows.extend(degree_rows)

            all_passages.append({
                "body": body,
                "retrogradePassage": passage_index,
                "startCelestialTimeDegrees": seg["startCelestialTimeDegrees"],
                "startCivicTimeOffsetSeconds": seg["startOffsetSeconds"],
                "startCivicTimeJulianDayUT": SATURN_START_JD + seg["startOffsetSeconds"] / 86400.0,
                "startSource": seg["startSource"],
                "endCelestialTimeDegrees": seg["endCelestialTimeDegrees"],
                "endCivicTimeOffsetSeconds": seg["endOffsetSeconds"],
                "endCivicTimeJulianDayUT": SATURN_START_JD + seg["endOffsetSeconds"] / 86400.0,
                "endSource": seg["endSource"],
                "celestialDegreesTraversedDecreasing": decreasing_distance(
                    seg["startCelestialTimeDegrees"], seg["endCelestialTimeDegrees"]
                ),
                "wholeDegreeCrossings": len(degree_rows),
            })

        by_body[body] = {
            "retrogradePassages": len(retro_segments),
            "retrogradeWholeDegreeCrossings": retro_degree_count,
            "explicitWholeDegreeTableBytesAt6PerRow": retro_degree_count * 6,
            "bitPackedDegreeAndUTBytesEstimate": (retro_degree_count * 41 + 7) // 8,
        }

    with (output_dir / "retrograde-passages.csv").open("w", newline="") as f:
        fields = [
            "body", "retrogradePassage",
            "startCelestialTimeDegrees", "startCivicTimeOffsetSeconds", "startCivicTimeJulianDayUT", "startSource",
            "endCelestialTimeDegrees", "endCivicTimeOffsetSeconds", "endCivicTimeJulianDayUT", "endSource",
            "celestialDegreesTraversedDecreasing", "wholeDegreeCrossings",
        ]
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(all_passages)

    with (output_dir / "retrograde-degree-crossings.csv").open("w", newline="") as f:
        fields = ["body", "retrogradePassage", "celestialTimeWholeDegree", "civicTimeOffsetSeconds", "civicTimeJulianDayUT"]
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(all_degree_rows)

    total_rows = len(all_degree_rows)
    summary = {
        "status": "Explicit retrograde celestial-time learning specimen; assembled without Ephemeris queries",
        "framing": "A retrograde passage is stored as decreasing planetary celestial time across increasing civic UT. The table records both the celestial-time span and the whole-degree celestial-time crossings inside it.",
        "saturnStartJulianDayUT": SATURN_START_JD,
        "saturnEndJulianDayUT": SATURN_END_JD,
        "byBody": by_body,
        "totalRetrogradePassages": len(all_passages),
        "totalRetrogradeWholeDegreeCrossings": total_rows,
        "explicitWholeDegreeTableBytesAt6PerRow": total_rows * 6,
        "bitPackedDegreeAndUTBytesEstimate": (total_rows * 41 + 7) // 8,
        "note": "Passage endpoints reuse the celestial-turn table. The explicit crossing table is measured even though direction is recoverable, so storage cost can be compared rather than assumed away.",
    }
    (output_dir / "summary.json").write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n")
    print(json.dumps(summary, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
