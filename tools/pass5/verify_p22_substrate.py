#!/usr/bin/env python3
"""Verify the committed P22 Mundane Timespine body substrate directly.

This verifier does not call Swiss Ephemeris and does not regenerate astronomy. It proves
that the persisted Pass 5 construction artifact still obeys the body-table contract earned
from the P22 study: span, resolutions, marker uniqueness, motion tables, file identity,
and internal ordering.
"""

from __future__ import annotations

import csv
import gzip
import hashlib
import json
import math
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DATA = ROOT / "p22-data"
RESULTS = ROOT / "p22-results"

P22_START_JD = 2386637.079399706
P22_END_JD = 2475819.1417904524
SPAN_NAME = "P22 Pluto Zeitgeist"
MAX_OFFSET_SECONDS = round((P22_END_JD - P22_START_JD) * 86400)

PROFILES = {
    "Sun": {"resolution": 1.0, "markers": ["Pluto", "Neptune"], "records": 87901},
    "Moon": {"resolution": 1.0, "markers": ["Sun", "Pluto"], "records": 1175112},
    "Mercury": {"resolution": 1.0, "markers": ["Sun", "Pluto", "Moon"], "records": 108604},
    "Venus": {"resolution": 1.0, "markers": ["Sun", "Pluto", "Mercury"], "records": 92858},
    "Mars": {"resolution": 1.0, "markers": ["Sun", "Pluto"], "records": 50512},
    "Jupiter": {"resolution": 0.1, "markers": ["Sun", "Pluto"], "records": 118545},
    "Saturn": {"resolution": 0.1, "markers": ["Sun", "Jupiter"], "records": 62000},
    "Uranus": {"resolution": 0.1, "markers": ["Sun"], "records": 29923},
    "Neptune": {"resolution": 0.1, "markers": ["Sun"], "records": 18933},
    "Pluto": {"resolution": 0.1, "markers": ["Sun"], "records": 14712},
    "NorthNode": {"resolution": 0.1, "markers": ["Sun", "Moon"], "records": 52867},
}

BASE_BODY_FIELDS = [
    "focalCelestialTick",
    "focalCelestialDegrees",
    "celestialResolutionDegrees",
    "occurrence",
    "utOffsetSeconds",
    "utJulianDay",
    "sequenceDirection",
]


def fail(message: str) -> None:
    raise AssertionError(message)


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def close(a: float, b: float, tolerance: float = 1e-9) -> bool:
    return abs(a - b) <= tolerance


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_json(path: Path):
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def verify_summary() -> dict[str, dict]:
    summary = load_json(DATA / "summary.json")
    require(summary["spanName"] == SPAN_NAME, "summary span changed")
    require(close(summary["startJulianDayUT"], P22_START_JD), "P22 start changed")
    require(close(summary["endJulianDayUT"], P22_END_JD), "P22 end changed")
    require(summary["civicOffsetBitsRequired"] == 33, "P22 civic offset width changed")
    require(len(summary["bodyTables"]) == 11, "P22 must contain eleven focal body tables")

    by_body = {row["body"]: row for row in summary["bodyTables"]}
    require(set(by_body) == set(PROFILES), "summary body set changed")

    total = 0
    for body, expected in PROFILES.items():
        row = by_body[body]
        require(close(float(row["selectedResolutionDegrees"]), expected["resolution"]), f"{body} resolution changed")
        require(row["selectedRecords"] == expected["records"], f"{body} record count changed")
        require(row["selectedResolutionMarkerAudit"]["selectedMarkers"] == expected["markers"], f"{body} markers changed")
        require(row["selectedResolutionMarkerAudit"]["selectedRepeatedKeys"] == 0, f"{body} marker audit is no longer unique")
        total += row["selectedRecords"]

    require(total == sum(p["records"] for p in PROFILES.values()), "profile record total mismatch")
    require(summary["totalSelectedBodyRecords"] == total, "summary totalSelectedBodyRecords mismatch")
    return by_body


def verify_manifest() -> None:
    manifest = load_json(DATA / "manifest.json")
    require(manifest["span"] == SPAN_NAME, "manifest span changed")
    require(manifest["bodyTableCount"] == 11, "manifest body table count changed")
    require(
        manifest["sharedTables"] == ["station-table", "retrograde-passages", "retrograde-crossings"],
        "manifest shared motion tables changed",
    )

    expected_paths = {f"body-tables/{body}.csv.gz" for body in PROFILES}
    expected_paths |= {"station-table.csv.gz", "retrograde-passages.csv.gz", "retrograde-crossings.csv.gz"}
    actual_paths = {record["path"] for record in manifest["files"]}
    require(actual_paths == expected_paths, "manifest file set changed")

    compressed_total = 0
    for record in manifest["files"]:
        path = DATA / record["path"]
        require(path.is_file(), f"missing persisted P22 file: {record['path']}")
        require(path.stat().st_size == record["compressedBytes"], f"compressed size changed: {record['path']}")
        require(record["uncompressedBytes"] > 0, f"invalid uncompressed byte count: {record['path']}")
        require(sha256(path) == record["sha256"], f"SHA-256 mismatch: {record['path']}")
        compressed_total += record["compressedBytes"]

    require(compressed_total == manifest["compressedBytesTotal"], "manifest compressed byte total mismatch")


def verify_compact_audit() -> None:
    audit = load_json(RESULTS / "substrate-audit-compact.json")
    require(audit["span"] == SPAN_NAME, "compact audit span changed")
    by_body = {row["body"]: row for row in audit["bodies"]}
    require(set(by_body) == set(PROFILES), "compact audit body set changed")
    for body, expected in PROFILES.items():
        row = by_body[body]
        require(close(float(row["resolution"]), expected["resolution"]), f"{body} compact-audit resolution mismatch")
        require(row["records"] == expected["records"], f"{body} compact-audit record mismatch")
        require(row["markers"] == expected["markers"], f"{body} compact-audit marker mismatch")
        require(row["markerUnique"] is True, f"{body} compact-audit key is not unique")


def verify_body_tables() -> dict[str, set[tuple[int, int]]]:
    decreasing: dict[str, set[tuple[int, int]]] = {}

    for body, expected in PROFILES.items():
        path = DATA / "body-tables" / f"{body}.csv.gz"
        marker_fields = [f"{marker}Degree" for marker in expected["markers"]]
        expected_fields = BASE_BODY_FIELDS + marker_fields
        seen_keys: set[tuple[int, ...]] = set()
        decreasing_rows: set[tuple[int, int]] = set()
        occurrences: Counter[int] = Counter()
        last_jd = -math.inf
        last_offset = -1
        records = 0
        cells = round(360 / expected["resolution"])

        with gzip.open(path, "rt", encoding="utf-8", newline="") as handle:
            reader = csv.DictReader(handle)
            require(reader.fieldnames == expected_fields, f"{body} schema changed: {reader.fieldnames}")

            for row in reader:
                records += 1
                tick = int(row["focalCelestialTick"])
                degree = float(row["focalCelestialDegrees"])
                resolution = float(row["celestialResolutionDegrees"])
                occurrence = int(row["occurrence"])
                offset = int(row["utOffsetSeconds"])
                jd = float(row["utJulianDay"])
                direction = row["sequenceDirection"]

                require(close(resolution, expected["resolution"], 1e-12), f"{body} row resolution changed")
                require(0 <= tick < cells, f"{body} focal tick out of range: {tick}")
                require(close(degree, tick * resolution, 1e-7), f"{body} degree/tick mismatch at row {records}")
                require(0 <= offset < MAX_OFFSET_SECONDS, f"{body} civic offset out of P22 range")
                require(P22_START_JD <= jd < P22_END_JD, f"{body} JD out of P22 range")
                require(jd > last_jd, f"{body} rows are not strictly ordered by civic time")
                require(offset >= last_offset, f"{body} rounded civic offsets reversed")
                require(direction in {"increasing", "decreasing"}, f"{body} invalid sequence direction")

                occurrences[tick] += 1
                require(occurrence == occurrences[tick], f"{body} occurrence numbering broke at tick {tick}")

                marker_values = tuple(int(row[field]) for field in marker_fields)
                require(all(0 <= value < 360 for value in marker_values), f"{body} marker degree out of range")
                key = (tick, *marker_values)
                require(key not in seen_keys, f"{body} repeated non-repeating marker key: {key}")
                seen_keys.add(key)

                if direction == "decreasing":
                    decreasing_rows.add((tick, offset))

                last_jd = jd
                last_offset = offset

        require(records == expected["records"], f"{body} body-table record count mismatch: {records}")
        decreasing[body] = decreasing_rows
        print(f"PASS body {body:10s} records={records:7d} uniqueKeys={len(seen_keys):7d}")

    return decreasing


def verify_station_table(summary_by_body: dict[str, dict]) -> None:
    counts: Counter[str] = Counter()
    path = DATA / "station-table.csv.gz"
    with gzip.open(path, "rt", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        expected_fields = [
            "body", "celestialTimeDegrees", "utOffsetSeconds", "utJulianDay",
            "sequenceBefore", "sequenceAfter", "userFacingStation",
        ]
        require(reader.fieldnames == expected_fields, "station table schema changed")
        for row in reader:
            body = row["body"]
            require(body in PROFILES, f"station table contains unknown body {body}")
            degree = float(row["celestialTimeDegrees"])
            offset = int(row["utOffsetSeconds"])
            jd = float(row["utJulianDay"])
            before = row["sequenceBefore"]
            after = row["sequenceAfter"]
            label = row["userFacingStation"]
            require(0 <= degree < 360, f"{body} station celestial time out of range")
            require(0 <= offset < MAX_OFFSET_SECONDS, f"{body} station offset out of range")
            require(P22_START_JD <= jd < P22_END_JD, f"{body} station JD out of range")
            require(before in {"increasing", "decreasing"} and after in {"increasing", "decreasing"}, f"{body} invalid station sequence")
            require(before != after, f"{body} station does not turn celestial-time direction")
            expected_label = "station_retrograde" if after == "decreasing" else "station_direct"
            require(label == expected_label, f"{body} user-facing station label mismatch")
            counts[body] += 1

    for body in PROFILES:
        require(counts[body] == summary_by_body[body]["stationCount"], f"{body} station count mismatch")
    print(f"PASS stations total={sum(counts.values())}")


def verify_retrograde_tables(summary_by_body: dict[str, dict], decreasing: dict[str, set[tuple[int, int]]]) -> None:
    passage_counts: Counter[str] = Counter()
    with gzip.open(DATA / "retrograde-passages.csv.gz", "rt", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        for row in reader:
            body = row["body"]
            require(body in PROFILES, f"retrograde passage contains unknown body {body}")
            start_offset = int(row["startOffsetSeconds"])
            end_offset = int(row["endOffsetSeconds"])
            start_jd = float(row["startJulianDay"])
            end_jd = float(row["endJulianDay"])
            require(0 <= start_offset <= end_offset <= MAX_OFFSET_SECONDS, f"{body} retrograde passage offset invalid")
            require(P22_START_JD <= start_jd <= end_jd <= P22_END_JD, f"{body} retrograde passage JD invalid")
            require(row["userFacingMotion"] == "retrograde", f"{body} retrograde user-facing term changed")
            passage_counts[body] += 1

    crossing_counts: Counter[str] = Counter()
    with gzip.open(DATA / "retrograde-crossings.csv.gz", "rt", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        for row in reader:
            body = row["body"]
            require(body in PROFILES, f"retrograde crossing contains unknown body {body}")
            tick = int(row["focalCelestialTick"])
            offset = int(row["utOffsetSeconds"])
            resolution = float(row["celestialResolutionDegrees"])
            require(close(resolution, PROFILES[body]["resolution"], 1e-12), f"{body} retrograde crossing resolution mismatch")
            require((tick, offset) in decreasing[body], f"{body} retrograde crossing is not a decreasing body-table occurrence")
            crossing_counts[body] += 1

    for body in PROFILES:
        require(passage_counts[body] == summary_by_body[body]["retrogradePassages"], f"{body} retrograde passage count mismatch")
        require(crossing_counts[body] == summary_by_body[body]["retrogradeSelectedCrossings"], f"{body} retrograde crossing count mismatch")
    print(f"PASS retrograde passages={sum(passage_counts.values())} crossings={sum(crossing_counts.values())}")


def main() -> None:
    summary_by_body = verify_summary()
    verify_manifest()
    verify_compact_audit()
    decreasing = verify_body_tables()
    verify_station_table(summary_by_body)
    verify_retrograde_tables(summary_by_body, decreasing)
    print("PASS P22 Mundane Timespine repository substrate")


if __name__ == "__main__":
    main()
