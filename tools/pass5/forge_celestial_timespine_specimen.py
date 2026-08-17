#!/usr/bin/env python3
"""Forge a bounded Mundane Timespine anatomy specimen in celestial time.

The specimen is bounded by successive Sun = 0 Aries occurrences. Civil/Julian
coordinates are retained only as resolved addresses of celestial boundaries.

This is a construction artifact for Pass 5 anatomy: BONE + TRACTS + NERVES.
It does not replace the qualified native codec until the representation is measured.
"""
from __future__ import annotations

import argparse
import bisect
import hashlib
import json
import math
from pathlib import Path
from typing import Protocol

BODY_NAMES = (
    "Sun", "Moon", "Mercury", "Venus", "Mars", "Jupiter", "Saturn",
    "Uranus", "Neptune", "Pluto", "True North Node",
)
BODY_IDS = {
    "Sun": 0, "Moon": 1, "Mercury": 2, "Venus": 3, "Mars": 4,
    "Jupiter": 5, "Saturn": 6, "Uranus": 7, "Neptune": 8,
    "Pluto": 9, "True North Node": 11,
}
VARIABLE_MOTION = {
    "Mercury", "Venus", "Mars", "Jupiter", "Saturn", "Uranus",
    "Neptune", "Pluto", "True North Node",
}
EPS_JD = 1e-9


class EphemerisBackend(Protocol):
    def state(self, jd: float, body: str) -> tuple[float, float]: ...


def normalize360(value: float) -> float:
    value %= 360.0
    return 0.0 if value == 0 else value


def motion_from_speed(speed: float) -> str:
    return "retrograde" if speed < 0 else "direct"


def directed_delta(start: float, end: float, motion: str) -> float:
    # Local tract hops are always far below 180 degrees. Resolve zodiac wrap by
    # shortest path, tolerating only microscopic contrary drift at a station.
    delta = ((end - start + 180.0) % 360.0) - 180.0
    if motion == "direct" and delta < 0 and abs(delta) <= 1e-5:
        return 0.0
    if motion == "retrograde" and delta > 0 and abs(delta) <= 1e-5:
        return 0.0
    return delta


def gregorian_jd(year: int, month: int, day: int) -> float:
    """Gregorian date at 00:00 UT, used only as an occurrence search locator."""
    if month <= 2:
        year -= 1
        month += 12
    a = year // 100
    b = 2 - a + a // 4
    return (
        math.floor(365.25 * (year + 4716))
        + math.floor(30.6001 * (month + 1))
        + day + b - 1524.5
    )


def solve_wrapped_target(
    backend: EphemerisBackend,
    body: str,
    left: float,
    right: float,
    left_lon: float,
    left_unwrapped: float,
    target_unwrapped: float,
    motion: str,
) -> float:
    increasing = motion == "direct"
    for _ in range(60):
        mid = (left + right) / 2.0
        mid_lon, _ = backend.state(mid, body)
        mid_unwrapped = left_unwrapped + directed_delta(left_lon, mid_lon, motion)
        if increasing:
            if mid_unwrapped < target_unwrapped:
                left = mid
            else:
                right = mid
        else:
            if mid_unwrapped > target_unwrapped:
                left = mid
            else:
                right = mid
    return (left + right) / 2.0


def find_sun_zero_aries(backend: EphemerisBackend, selector_year: int) -> float:
    """Resolve Sun = 0 Aries; the civil year is only an occurrence selector."""
    left = gregorian_jd(selector_year, 3, 15)
    lon_left, speed_left = backend.state(left, "Sun")
    for _ in range(16):
        right = left + 1.0
        lon_right, speed_right = backend.state(right, "Sun")
        if lon_left > 350.0 and lon_right < 10.0 and speed_left > 0:
            return solve_wrapped_target(
                backend, "Sun", left, right, lon_left, lon_left, 360.0, "direct"
            )
        left, lon_left, speed_left = right, lon_right, speed_right
    raise RuntimeError(f"Could not resolve Sun = 0 Aries for selector year {selector_year}")


def solve_station(
    backend: EphemerisBackend, body: str, left: float, right: float, left_speed: float
) -> float:
    for _ in range(60):
        mid = (left + right) / 2.0
        _, speed = backend.state(mid, body)
        if (left_speed < 0) == (speed < 0):
            left, left_speed = mid, speed
        else:
            right = mid
    return (left + right) / 2.0


def station_chronology(
    backend: EphemerisBackend, body: str, start: float, end: float
) -> dict:
    _, initial_speed = backend.state(start + 1e-8, body)
    initial_motion = motion_from_speed(initial_speed)
    if body not in VARIABLE_MOTION:
        return {"initialMotion": initial_motion, "stations": []}

    step = 0.05 if body == "True North Node" else 0.20
    roots: list[dict] = []
    left = start
    _, left_speed = backend.state(left + 1e-8, body)
    while left < end:
        right = min(end, left + step)
        _, right_speed = backend.state(max(left + 1e-8, right - 1e-8), body)
        if (left_speed < 0) != (right_speed < 0):
            root = solve_station(backend, body, left, right, left_speed)
            if root > start + EPS_JD and root < end - EPS_JD:
                motion_after = "direct" if left_speed < 0 else "retrograde"
                if not roots or root - roots[-1]["julianDay"] > 1e-7:
                    roots.append({"julianDay": root, "motionAfter": motion_after})
        left, left_speed = right, right_speed
    return {"initialMotion": initial_motion, "stations": roots}


def motion_runs(chronology: dict, start: float, end: float) -> list[dict]:
    cuts = [start] + [s["julianDay"] for s in chronology["stations"]] + [end]
    motion = chronology["initialMotion"]
    runs = []
    for i, (a, b) in enumerate(zip(cuts, cuts[1:])):
        runs.append({"id": i, "start": a, "end": b, "motion": motion})
        if i < len(chronology["stations"]):
            motion = chronology["stations"][i]["motionAfter"]
    return runs


def crossing_scan_step(speed: float) -> float:
    magnitude = max(abs(speed), 0.01)
    return min(1.0, max(1.0 / 288.0, 0.35 / magnitude))


def degree_crossings(
    backend: EphemerisBackend, body: str, runs: list[dict], start: float, end: float
) -> list[dict]:
    crossings: list[dict] = []
    for run in runs:
        motion = run["motion"]
        left = run["start"]
        lon_left, speed_left = backend.state(min(end - 1e-10, left + 1e-10), body)
        unwrapped_left = lon_left

        while left < run["end"] - 1e-12:
            right = min(run["end"], left + crossing_scan_step(speed_left))
            lon_right, speed_right = backend.state(max(left + 1e-10, right - 1e-10), body)
            delta = directed_delta(lon_left, lon_right, motion)
            if abs(delta) > 2.0:
                raise RuntimeError(f"{body} crossing scan jumped {delta:.6f} degrees")
            unwrapped_right = unwrapped_left + delta

            targets: list[int] = []
            if motion == "direct":
                target = math.floor(unwrapped_left + 1e-10) + 1
                while target <= unwrapped_right + 1e-10:
                    targets.append(target)
                    target += 1
            else:
                target = math.ceil(unwrapped_left - 1e-10) - 1
                while target >= unwrapped_right - 1e-10:
                    targets.append(target)
                    target -= 1

            for target in targets:
                root = solve_wrapped_target(
                    backend, body, left, right, lon_left, unwrapped_left,
                    float(target), motion,
                )
                if root <= start + EPS_JD or root >= end - EPS_JD:
                    continue
                record = {
                    "julianDay": root,
                    "degree": int(target) % 360,
                    "motion": motion,
                }
                if not crossings or root - crossings[-1]["julianDay"] > 1e-8:
                    crossings.append(record)

            left = right
            lon_left, speed_left = lon_right, speed_right
            unwrapped_left = unwrapped_right
    return crossings


def nearest_previous_station(stations: list[dict], jd: float) -> float | None:
    values = [s["julianDay"] for s in stations]
    i = bisect.bisect_right(values, jd) - 1
    return values[i] if i >= 0 else None


def nearest_next_station(stations: list[dict], jd: float) -> float | None:
    values = [s["julianDay"] for s in stations]
    i = bisect.bisect_left(values, jd)
    return values[i] if i < len(values) else None


def build_tract(
    backend: EphemerisBackend,
    body: str,
    start: float,
    end: float,
    chronology: dict,
    crossings: list[dict],
) -> dict:
    own_boundaries = [start, end]
    own_boundaries.extend(s["julianDay"] for s in chronology["stations"])
    own_boundaries.extend(c["julianDay"] for c in crossings)
    own_boundaries.sort()

    deduped = []
    for value in own_boundaries:
        if not deduped or value - deduped[-1] > EPS_JD:
            deduped.append(value)

    segments = []
    cell_index: dict[str, dict[str, list[int]]] = {}
    for segment_id, (a, b) in enumerate(zip(deduped, deduped[1:])):
        midpoint = (a + b) / 2.0
        lon_a, _ = backend.state(a, body)
        lon_b, _ = backend.state(b, body)
        lon_mid, speed_mid = backend.state(midpoint, body)
        motion = motion_from_speed(speed_mid)
        delta = directed_delta(lon_a, lon_b, motion)
        if abs(delta) > 1.000001:
            raise RuntimeError(f"{body} tract segment {segment_id} spans {delta:.9f} degrees")
        u_end = lon_a + delta
        degree_cell = int(math.floor(normalize360(lon_mid)))
        segment = {
            "id": segment_id,
            "timeStart": a,
            "timeEnd": b,
            "longitudeStart": normalize360(lon_a),
            "longitudeEnd": normalize360(lon_b),
            "unwrappedLongitudeMin": min(lon_a, u_end),
            "unwrappedLongitudeMax": max(lon_a, u_end),
            "degreeCell": degree_cell,
            "motion": motion,
            "previousStation": nearest_previous_station(chronology["stations"], a + EPS_JD),
            "nextStation": nearest_next_station(chronology["stations"], b - EPS_JD),
        }
        segments.append(segment)
        cell_index.setdefault(str(degree_cell), {}).setdefault(motion, []).append(segment_id)

    runs = motion_runs(chronology, start, end)
    for run in runs:
        lon_a, _ = backend.state(run["start"], body)
        lon_b, _ = backend.state(run["end"], body)
        run["longitudeStart"] = normalize360(lon_a)
        run["longitudeEnd"] = normalize360(lon_b)
        matching = [
            s["id"] for s in segments
            if s["timeStart"] >= run["start"] - EPS_JD
            and s["timeEnd"] <= run["end"] + EPS_JD
        ]
        run["tractSegmentStart"] = matching[0] if matching else None
        run["tractSegmentEnd"] = matching[-1] if matching else None

    return {
        "initialMotion": chronology["initialMotion"],
        "stations": chronology["stations"],
        "segments": segments,
        "motionRuns": runs,
        "longitudeCellIndex": cell_index,
    }


def group_bone_boundaries(events: list[dict], start: float, end: float) -> list[dict]:
    events.sort(key=lambda e: e["julianDay"])
    groups: list[dict] = []
    for event in events:
        jd = event["julianDay"]
        if jd < start - EPS_JD or jd > end + EPS_JD:
            continue
        if groups and abs(jd - groups[-1]["julianDay"]) <= EPS_JD:
            groups[-1]["events"].append({k: v for k, v in event.items() if k != "julianDay"})
        else:
            groups.append({
                "id": len(groups),
                "julianDay": jd,
                "events": [{k: v for k, v in event.items() if k != "julianDay"}],
            })
    if not groups or abs(groups[0]["julianDay"] - start) > EPS_JD:
        raise RuntimeError("Bone does not begin on the celestial start anchor")
    if abs(groups[-1]["julianDay"] - end) > EPS_JD:
        raise RuntimeError("Bone does not end on the celestial end anchor")
    return groups


def segment_at(segments: list[dict], starts: list[float], jd: float) -> int:
    i = bisect.bisect_right(starts, jd) - 1
    if i < 0:
        i = 0
    if i >= len(segments):
        i = len(segments) - 1
    segment = segments[i]
    if not (segment["timeStart"] - EPS_JD <= jd < segment["timeEnd"] + EPS_JD):
        raise RuntimeError("Vertebra midpoint escaped its tract segment")
    return segment["id"]


def build_specimen(
    backend: EphemerisBackend,
    start_selector_year: int,
    end_selector_year: int,
    source: dict,
) -> dict:
    start = find_sun_zero_aries(backend, start_selector_year)
    end = find_sun_zero_aries(backend, end_selector_year)
    if not start < end:
        raise RuntimeError("Celestial anchors are not ordered")

    start_lon, start_speed = backend.state(start, "Sun")
    end_lon, end_speed = backend.state(end, "Sun")
    if min(start_lon, 360.0 - start_lon) > 1e-7 or min(end_lon, 360.0 - end_lon) > 1e-7:
        raise RuntimeError("Sun anchor failed 0 Aries condition")
    if start_speed <= 0 or end_speed <= 0:
        raise RuntimeError("Sun 0 Aries anchor is not direct")

    tracts: dict[str, dict] = {}
    all_events = [
        {"julianDay": start, "kind": "anchorStart", "body": "Sun", "degree": 0, "motion": "direct"},
        {"julianDay": end, "kind": "anchorEnd", "body": "Sun", "degree": 0, "motion": "direct"},
    ]

    crossing_records: dict[str, list[dict]] = {}
    for body in BODY_NAMES:
        chronology = station_chronology(backend, body, start, end)
        runs = motion_runs(chronology, start, end)
        crossings = degree_crossings(backend, body, runs, start, end)
        crossing_records[body] = crossings
        tract = build_tract(backend, body, start, end, chronology, crossings)
        tracts[body] = tract

        for station in chronology["stations"]:
            all_events.append({
                "julianDay": station["julianDay"],
                "kind": "station",
                "body": body,
                "motionAfter": station["motionAfter"],
            })
        for crossing in crossings:
            all_events.append({
                "julianDay": crossing["julianDay"],
                "kind": "degreeCrossing",
                "body": body,
                "degree": crossing["degree"],
                "motion": crossing["motion"],
            })

    boundaries = group_bone_boundaries(all_events, start, end)
    boundary_jds = [b["julianDay"] for b in boundaries]

    for tract in tracts.values():
        for segment in tract["segments"]:
            segment["startBoundary"] = bisect.bisect_left(boundary_jds, segment["timeStart"] - EPS_JD)
            segment["endBoundary"] = bisect.bisect_left(boundary_jds, segment["timeEnd"] - EPS_JD)

    starts_by_body = {
        body: [s["timeStart"] for s in tract["segments"]]
        for body, tract in tracts.items()
    }
    vertebrae = []
    for i in range(len(boundaries) - 1):
        midpoint = (boundaries[i]["julianDay"] + boundaries[i + 1]["julianDay"]) / 2.0
        vertebrae.append({
            "id": i,
            "startBoundary": i,
            "endBoundary": i + 1,
            "tractRefs": {
                body: segment_at(tracts[body]["segments"], starts_by_body[body], midpoint)
                for body in BODY_NAMES
            },
        })

    degree_crossing_index: dict[str, dict] = {}
    for body in BODY_NAMES:
        body_index: dict[str, dict[str, list[int]]] = {}
        for crossing in crossing_records[body]:
            j = bisect.bisect_left(boundary_jds, crossing["julianDay"] - EPS_JD)
            if j >= len(boundary_jds) or abs(boundary_jds[j] - crossing["julianDay"]) > 2 * EPS_JD:
                raise RuntimeError("Crossing did not land on a bone boundary")
            body_index.setdefault(str(crossing["degree"]), {}).setdefault(crossing["motion"], []).append(j)
        degree_crossing_index[body] = body_index

    bone = {
        "boundaryCount": len(boundaries),
        "vertebraCount": len(vertebrae),
        "boundaries": boundaries,
        "vertebrae": vertebrae,
    }
    nerves = {
        "degreeCrossingIndex": degree_crossing_index,
        "longitudeCellIndex": {
            body: tracts[body]["longitudeCellIndex"] for body in BODY_NAMES
        },
        "motionRuns": {
            body: tracts[body]["motionRuns"] for body in BODY_NAMES
        },
    }

    mercury_8 = degree_crossing_index["Mercury"].get("8", {})
    proof = {
        "allVertebraeReferenceAllBodies": all(
            len(v["tractRefs"]) == len(BODY_NAMES) for v in vertebrae
        ),
        "mercury8AriesBoundaryHits": sum(len(v) for v in mercury_8.values()),
        "startSunLongitude": normalize360(start_lon),
        "endSunLongitude": normalize360(end_lon),
    }

    return {
        "schema": "orbo-mundane-timespine-celestial-specimen-v1",
        "status": "construction specimen; representation not yet canonical",
        "source": source,
        "celestialBounds": {
            "intervalLaw": "half-open",
            "start": {
                "condition": {"body": "Sun", "longitude": 0.0, "motion": "direct"},
                "resolvedAddress": {"julianDay": start},
                "selectorYear": start_selector_year,
            },
            "end": {
                "condition": {"body": "Sun", "longitude": 0.0, "motion": "direct"},
                "resolvedAddress": {"julianDay": end},
                "selectorYear": end_selector_year,
            },
        },
        "anatomy": {
            "bone": bone,
            "tracts": {
                body: {
                    "segments": tracts[body]["segments"],
                    "stationChronology": {
                        "initialMotion": tracts[body]["initialMotion"],
                        "stations": tracts[body]["stations"],
                    },
                }
                for body in BODY_NAMES
            },
            "nerves": nerves,
        },
        "proof": proof,
        "counts": {
            "boneBoundaries": len(boundaries),
            "vertebrae": len(vertebrae),
            "tractSegments": {body: len(tracts[body]["segments"]) for body in BODY_NAMES},
            "degreeCrossings": {body: len(crossing_records[body]) for body in BODY_NAMES},
            "stations": {body: len(tracts[body]["stations"]) for body in BODY_NAMES},
        },
    }


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--library", required=True)
    parser.add_argument("--ephe-dir", required=True)
    parser.add_argument("--start-selector-year", type=int, default=1985)
    parser.add_argument("--end-selector-year", type=int, default=1986)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    from generate_swiss_samples import SwissC, verify_files

    ephe_dir = Path(args.ephe_dir)
    files = verify_files(ephe_dir)
    swiss = SwissC(Path(args.library), ephe_dir)

    class QualifiedSwissBackend:
        def state(self, jd: float, body: str) -> tuple[float, float]:
            return swiss.state(jd, BODY_IDS[body])

    source = {
        "astronomicalEngine": "official Swiss Ephemeris C library",
        "swissLibraryVersion": swiss.version,
        "ephemerisFiles": files,
        "coordinateContract": {
            "center": "geocentric",
            "zodiac": "tropical",
            "frame": "ecliptic of date",
            "position": "standard apparent Swiss Ephemeris position",
            "speed": "SEFLG_SPEED",
            "northNode": "true / osculating",
        },
    }

    try:
        specimen = build_specimen(
            QualifiedSwissBackend(),
            args.start_selector_year,
            args.end_selector_year,
            source,
        )
        output = Path(args.output)
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(specimen, indent=2, sort_keys=True) + "\n")
        print(json.dumps({
            "output": str(output),
            "bytes": output.stat().st_size,
            "sha256": sha256(output),
            "celestialBounds": specimen["celestialBounds"],
            "counts": specimen["counts"],
            "proof": specimen["proof"],
        }, indent=2, sort_keys=True))
    finally:
        swiss.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
