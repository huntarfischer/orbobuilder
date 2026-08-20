#!/usr/bin/env python3
"""Manufacture canonical Pluto Shell.sign segments for Z21-Z23.

Shell.sign law:
  <shell-id>.<01-12> is the stable zodiacal subdivision inside a numbered shell.
  01=Aries ... 12=Pisces.
  A segment begins at the first direct ingress into its sign and owns the interval
  until the first direct ingress into the following sign. Retrograde recrossings
  are transition metadata and never renumber the segment.

This first manufacturer applies the generic law to Pluto Zeitgeists Z21-Z23.
It imports the same Swiss C wrapper and DE441 verification contract used by the
canonical Pass 5 temporal-shell forge and aborts on Moshier fallback.
"""
from __future__ import annotations

import argparse
import csv
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate_temporal_shell_tables as base

PLUTO = 9
SIGNS = (
    "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
    "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces",
)
STEP_DAYS = 5.0


def signed_target(longitude: float, target: float) -> float:
    return ((longitude - target + 180.0) % 360.0) - 180.0


def refine_target_crossing(swiss: base.SwissC, lo: float, hi: float, target: float, direct: bool) -> dict:
    for _ in range(64):
        mid = (lo + hi) / 2.0
        fm = signed_target(swiss.state(mid, PLUTO)[0], target)
        if direct:
            if fm >= 0.0:
                hi = mid
            else:
                lo = mid
        else:
            if fm <= 0.0:
                hi = mid
            else:
                lo = mid
    jd = (lo + hi) / 2.0
    _, speed = swiss.state(jd, PLUTO)
    motion = "direct" if speed > 0.0 else "retrograde"
    expected = "direct" if direct else "retrograde"
    if motion != expected:
        raise RuntimeError(f"Pluto target crossing motion mismatch at {swiss.utc(jd)}: {motion} != {expected}")
    return {"jd_ut": jd, "utc": swiss.utc(jd), "motion": motion}


def crossings_between(swiss: base.SwissC, target: float, start: float, end: float) -> list[dict]:
    """Return all real crossings of target in (start,end), excluding angular-wrap artifacts."""
    out: list[dict] = []
    t0 = start
    d0 = signed_target(swiss.state(t0, PLUTO)[0], target)
    while t0 < end:
        t1 = min(end, t0 + STEP_DAYS)
        d1 = signed_target(swiss.state(t1, PLUTO)[0], target)
        # Pluto cannot move remotely close to 30 degrees in five days. This guard
        # rejects the signed-angle discontinuity 180 degrees away from the target.
        if abs(d1 - d0) < 30.0:
            if d0 < 0.0 <= d1:
                out.append(refine_target_crossing(swiss, t0, t1, target, True))
            elif d0 > 0.0 >= d1:
                out.append(refine_target_crossing(swiss, t0, t1, target, False))
        t0, d0 = t1, d1
    # Deduplicate a crossing that lands exactly on a scan seam.
    deduped: list[dict] = []
    for c in out:
        if not deduped or abs(c["jd_ut"] - deduped[-1]["jd_ut"]) > 1e-6:
            deduped.append(c)
    return deduped


def first_direct_crossing(swiss: base.SwissC, target: float, start: float, end: float) -> dict:
    for c in crossings_between(swiss, target, start, end):
        if c["motion"] == "direct":
            return c
    raise RuntimeError(f"No direct Pluto crossing of {target:.0f} degrees between {swiss.utc(start)} and {swiss.utc(end)}")


def manufacture(swiss: base.SwissC) -> list[dict]:
    rows: list[dict] = []
    for zid in ("Z21", "Z22", "Z23"):
        shell_start, shell_end = base.Z_BOUNDS[zid]
        shell_start_utc, shell_end_utc = base.Z_UTC[zid]

        starts: list[dict] = [{
            "jd_ut": shell_start,
            "utc": shell_start_utc,
            "motion": "direct",
        }]
        cursor = shell_start + 1e-5
        for ordinal in range(2, 13):
            target = float((ordinal - 1) * 30)
            crossing = first_direct_crossing(swiss, target, cursor, shell_end)
            starts.append(crossing)
            cursor = crossing["jd_ut"] + 1e-5

        boundaries = starts + [{
            "jd_ut": shell_end,
            "utc": shell_end_utc,
            "motion": "direct",
        }]

        for i in range(12):
            ordinal = i + 1
            target = float(i * 30)
            first = starts[i]
            next_first = boundaries[i + 1]

            transition = [dict(first)]
            # Search after the first ingress for any retrograde/direct recrossings
            # of this same sign boundary before the next sign segment begins.
            later = crossings_between(
                swiss,
                target,
                first["jd_ut"] + 0.01,
                next_first["jd_ut"],
            )
            for c in later:
                if abs(c["jd_ut"] - first["jd_ut"]) > 1e-5:
                    transition.append(c)

            rows.append({
                "shell_sign_id": f"{zid}.{ordinal:02d}",
                "shell_id": zid,
                "sign_ordinal": ordinal,
                "sign_name": SIGNS[i],
                "sign_start_degree": int(target),
                "first_direct_ingress_jd_ut": first["jd_ut"],
                "first_direct_ingress_utc": first["utc"],
                "next_sign_first_direct_ingress_jd_ut": next_first["jd_ut"],
                "next_sign_first_direct_ingress_utc": next_first["utc"],
                "transition_crossings": transition,
                "transition_crossing_count": len(transition),
            })
    return rows


def audit(rows: list[dict]) -> dict:
    failures: list[str] = []
    if len(rows) != 36:
        failures.append(f"row_count={len(rows)} expected=36")

    for zid in ("Z21", "Z22", "Z23"):
        zr = [r for r in rows if r["shell_id"] == zid]
        if [r["sign_ordinal"] for r in zr] != list(range(1, 13)):
            failures.append(f"{zid}: sign ordinals are not 01-12")
        if [r["sign_name"] for r in zr] != list(SIGNS):
            failures.append(f"{zid}: sign-name order drift")
        if zr:
            if abs(zr[0]["first_direct_ingress_jd_ut"] - base.Z_BOUNDS[zid][0]) > 1e-9:
                failures.append(f"{zid}.01 does not begin exactly at {zid} ingress")
            if abs(zr[-1]["next_sign_first_direct_ingress_jd_ut"] - base.Z_BOUNDS[zid][1]) > 1e-9:
                failures.append(f"{zid}.12 does not end exactly at next Zeitgeist ingress")
        for a, b in zip(zr, zr[1:]):
            if abs(a["next_sign_first_direct_ingress_jd_ut"] - b["first_direct_ingress_jd_ut"]) > 1e-9:
                failures.append(f"{a['shell_sign_id']}->{b['shell_sign_id']}: non-contiguous boundary")
            if a["first_direct_ingress_jd_ut"] >= b["first_direct_ingress_jd_ut"]:
                failures.append(f"{zid}: starts not strictly increasing")
        for r in zr:
            if not r["transition_crossings"] or r["transition_crossings"][0]["motion"] != "direct":
                failures.append(f"{r['shell_sign_id']}: first transition crossing is not direct")

    return {
        "status": "PASS" if not failures else "FAIL",
        "row_count": len(rows),
        "shells": ["Z21", "Z22", "Z23"],
        "sign_numbering": {f"{i+1:02d}": sign for i, sign in enumerate(SIGNS)},
        "law": "Shell.sign uses 01-12 Aries-Pisces; first direct sign ingress begins stable ownership and retrograde recrossings remain transition metadata.",
        "failures": failures,
    }


def write_outputs(out_dir: Path, rows: list[dict], provenance: dict, audit_doc: dict) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    doc = {
        "schema_version": "1.0.0",
        "scope": "Z21.01 through Z23.12",
        "notation": "Shell.sign",
        "ownership": "[first_direct_ingress, next_sign_first_direct_ingress)",
        "numbering_law": "01=Aries through 12=Pisces inside each numbered temporal shell; retrograde recrossings do not renumber the segment.",
        "provenance": provenance,
        "rows": rows,
    }
    (out_dir / "plutonian-zeitgeist-sign-table-z21-z23.json").write_text(
        json.dumps(doc, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )

    csv_rows = []
    for row in rows:
        flat = dict(row)
        flat["transition_crossings"] = json.dumps(flat["transition_crossings"], separators=(",", ":"))
        csv_rows.append(flat)
    fields = list(csv_rows[0].keys())
    with (out_dir / "plutonian-zeitgeist-sign-table-z21-z23.csv").open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(csv_rows)

    (out_dir / "plutonian-zeitgeist-sign-z21-z23-summary.json").write_text(
        json.dumps(audit_doc, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--library", type=Path, required=True)
    p.add_argument("--ephe-dir", type=Path, required=True)
    p.add_argument("--out-dir", type=Path, required=True)
    p.add_argument("--source-commit", required=True)
    args = p.parse_args()

    ephe_files = base.verify_ephe(args.ephe_dir)
    swiss = base.SwissC(args.library, args.ephe_dir)
    try:
        rows = manufacture(swiss)
        audit_doc = audit(rows)
        if audit_doc["status"] != "PASS":
            raise RuntimeError("Plutonian Shell.sign audit failed: " + "; ".join(audit_doc["failures"]))
        provenance = {
            "astronomical_engine": "official Swiss Ephemeris C",
            "swiss_ephemeris_version": swiss.version,
            "source_repository": "huntarfischer/swisseph",
            "source_commit": args.source_commit,
            "ephemeris_generation": "DE441",
            "ephemeris_files": ephe_files,
            "flags": "SEFLG_SWIEPH | SEFLG_SPEED",
            "coordinate_contract": {
                "center": "geocentric",
                "frame": "ecliptic of date",
                "zodiac": "tropical",
            },
        }
        write_outputs(args.out_dir, rows, provenance, audit_doc)
    finally:
        swiss.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
