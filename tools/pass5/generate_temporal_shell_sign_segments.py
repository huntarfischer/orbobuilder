#!/usr/bin/env python3
"""Manufacture canonical Shell.sign tables for Neptune, Uranus, and Saturn.

Generic Shell.sign law:
  <shell-id>.<01-12> is the stable zodiacal subdivision inside a numbered shell.
  01=Aries ... 12=Pisces.
  A segment begins at the first direct ingress into its sign and owns the interval
  until the first direct ingress into the following sign. Retrograde recrossings
  are transition metadata and never renumber the segment.

This manufacturer consumes the already-manufactured canonical W/R/F shell tables
and uses the same pinned Swiss C + DE441 contract to solve exact sign boundaries.
"""
from __future__ import annotations

import argparse
import csv
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate_temporal_shell_tables as base

SIGNS = (
    "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
    "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces",
)

FAMILIES = {
    "W": {
        "body": 8,
        "planet": "Neptune",
        "family": "Neptunian Wave",
        "source": "neptunian-wave-table.json",
        "stem": "neptunian-wave-sign-table",
        "summary": "neptunian-wave-sign-summary.json",
        "step": 10.0,
    },
    "R": {
        "body": 7,
        "planet": "Uranus",
        "family": "Uranian Revolt",
        "source": "uranian-revolt-table.json",
        "stem": "uranian-revolt-sign-table",
        "summary": "uranian-revolt-sign-summary.json",
        "step": 5.0,
    },
    "F": {
        "body": 6,
        "planet": "Saturn",
        "family": "Saturnian Frame",
        "source": "saturnian-frame-table.json",
        "stem": "saturnian-frame-sign-table",
        "summary": "saturnian-frame-sign-summary.json",
        "step": 2.0,
    },
}


def signed_target(longitude: float, target: float) -> float:
    return ((longitude - target + 180.0) % 360.0) - 180.0


def refine_target_crossing(
    swiss: base.SwissC,
    body: int,
    lo: float,
    hi: float,
    target: float,
    direct: bool,
) -> dict:
    for _ in range(64):
        mid = (lo + hi) / 2.0
        fm = signed_target(swiss.state(mid, body)[0], target)
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
    lon, speed = swiss.state(jd, body)
    motion = "direct" if speed > 0.0 else "retrograde"
    expected = "direct" if direct else "retrograde"
    if motion != expected:
        raise RuntimeError(
            f"Target crossing motion mismatch body={body} target={target} "
            f"at {swiss.utc(jd)}: {motion} != {expected}"
        )
    if abs(signed_target(lon, target)) > 1e-7:
        raise RuntimeError(
            f"Target crossing longitude drift body={body} target={target} "
            f"at {swiss.utc(jd)}: lon={lon}"
        )
    return {"jd_ut": jd, "utc": swiss.utc(jd), "motion": motion}


def scan_shell_crossings(
    swiss: base.SwissC,
    body: int,
    start: float,
    end: float,
    step: float,
) -> dict[int, list[dict]]:
    """Scan one shell once and collect crossings of 30..330 degree boundaries."""
    out = {degree: [] for degree in range(30, 360, 30)}
    t0 = start + 1e-5
    lon0, _ = swiss.state(t0, body)
    while t0 < end - 1e-5:
        t1 = min(end - 1e-5, t0 + step)
        lon1, _ = swiss.state(t1, body)
        delta = lon1 - lon0
        # Reject the 0-Aries wrap. Internal sign boundaries never wrap.
        if abs(delta) < 30.0:
            if delta > 0.0:
                for target in range(30, 360, 30):
                    if lon0 < target <= lon1:
                        out[target].append(
                            refine_target_crossing(swiss, body, t0, t1, float(target), True)
                        )
            elif delta < 0.0:
                for target in range(30, 360, 30):
                    if lon1 <= target < lon0:
                        out[target].append(
                            refine_target_crossing(swiss, body, t0, t1, float(target), False)
                        )
        t0, lon0 = t1, lon1

    for target, crossings in out.items():
        deduped = []
        for c in crossings:
            if not deduped or abs(c["jd_ut"] - deduped[-1]["jd_ut"]) > 1e-6:
                deduped.append(c)
        out[target] = deduped
    return out


def load_source(out_dir: Path, cfg: dict) -> tuple[dict, list[dict]]:
    path = out_dir / cfg["source"]
    if not path.is_file():
        raise RuntimeError(f"Missing canonical shell source table: {path}")
    doc = json.loads(path.read_text(encoding="utf-8"))
    rows = doc.get("rows")
    if not isinstance(rows, list) or not rows:
        raise RuntimeError(f"Canonical shell source has no rows: {path}")
    return doc, rows


def manufacture_family(
    swiss: base.SwissC,
    prefix: str,
    cfg: dict,
    source_rows: list[dict],
) -> list[dict]:
    rows: list[dict] = []
    body = cfg["body"]

    for shell in source_rows:
        shell_id = shell["shell_id"]
        shell_start = float(shell["first_aries_ingress_jd_ut"])
        shell_end = float(shell["next_shell_first_aries_ingress_jd_ut"])
        shell_start_utc = shell["first_aries_ingress_utc"]
        shell_end_utc = shell["next_shell_first_aries_ingress_utc"]

        crossing_map = scan_shell_crossings(
            swiss, body, shell_start, shell_end, cfg["step"]
        )

        starts = [{
            "jd_ut": shell_start,
            "utc": shell_start_utc,
            "motion": "direct",
        }]
        for target in range(30, 360, 30):
            direct = next(
                (c for c in crossing_map[target] if c["motion"] == "direct"),
                None,
            )
            if direct is None:
                raise RuntimeError(
                    f"{shell_id}: no direct crossing found for {target} degrees"
                )
            starts.append(direct)

        boundaries = starts + [{
            "jd_ut": shell_end,
            "utc": shell_end_utc,
            "motion": "direct",
        }]

        for i in range(12):
            ordinal = i + 1
            target = i * 30
            first = starts[i]
            next_first = boundaries[i + 1]

            if i == 0:
                transition = [
                    {
                        "jd_ut": float(c["jd_ut"]),
                        "utc": c["utc"],
                        "motion": c["motion"],
                    }
                    for c in shell.get("transition_crossings", [])
                    if shell_start - 1e-7 <= float(c["jd_ut"]) < next_first["jd_ut"]
                ]
                if not transition or abs(transition[0]["jd_ut"] - shell_start) > 1e-6:
                    transition.insert(0, dict(first))
            else:
                transition = [
                    c for c in crossing_map[target]
                    if first["jd_ut"] - 1e-7 <= c["jd_ut"] < next_first["jd_ut"]
                ]
                if not transition or abs(transition[0]["jd_ut"] - first["jd_ut"]) > 1e-6:
                    transition.insert(0, dict(first))

            rows.append({
                "shell_sign_id": f"{shell_id}.{ordinal:02d}",
                "shell_id": shell_id,
                "shell_ordinal": int(shell["ordinal"]),
                "sign_ordinal": ordinal,
                "sign_name": SIGNS[i],
                "sign_start_degree": target,
                "first_direct_ingress_jd_ut": first["jd_ut"],
                "first_direct_ingress_utc": first["utc"],
                "next_sign_first_direct_ingress_jd_ut": next_first["jd_ut"],
                "next_sign_first_direct_ingress_utc": next_first["utc"],
                "transition_crossings": transition,
                "transition_crossing_count": len(transition),
            })

    return rows


def audit_family(
    prefix: str,
    cfg: dict,
    source_rows: list[dict],
    rows: list[dict],
) -> dict:
    failures: list[str] = []
    expected_count = len(source_rows) * 12
    if len(rows) != expected_count:
        failures.append(f"row_count={len(rows)} expected={expected_count}")

    by_shell = {shell["shell_id"]: [] for shell in source_rows}
    for row in rows:
        by_shell.setdefault(row["shell_id"], []).append(row)

    for shell in source_rows:
        shell_id = shell["shell_id"]
        sr = by_shell.get(shell_id, [])
        if [r["sign_ordinal"] for r in sr] != list(range(1, 13)):
            failures.append(f"{shell_id}: sign ordinals are not 01-12")
            continue
        if [r["sign_name"] for r in sr] != list(SIGNS):
            failures.append(f"{shell_id}: sign-name order drift")
        if abs(sr[0]["first_direct_ingress_jd_ut"] - float(shell["first_aries_ingress_jd_ut"])) > 1e-9:
            failures.append(f"{shell_id}.01 does not begin exactly at shell ingress")
        if abs(sr[-1]["next_sign_first_direct_ingress_jd_ut"] - float(shell["next_shell_first_aries_ingress_jd_ut"])) > 1e-9:
            failures.append(f"{shell_id}.12 does not end exactly at next shell ingress")
        for a, b in zip(sr, sr[1:]):
            if abs(a["next_sign_first_direct_ingress_jd_ut"] - b["first_direct_ingress_jd_ut"]) > 1e-9:
                failures.append(f"{a['shell_sign_id']}->{b['shell_sign_id']}: non-contiguous boundary")
            if a["first_direct_ingress_jd_ut"] >= b["first_direct_ingress_jd_ut"]:
                failures.append(f"{shell_id}: starts not strictly increasing")
        for r in sr:
            if not r["transition_crossings"]:
                failures.append(f"{r['shell_sign_id']}: no transition crossings")
            elif r["transition_crossings"][0]["motion"] != "direct":
                failures.append(f"{r['shell_sign_id']}: first transition crossing is not direct")

    return {
        "status": "PASS" if not failures else "FAIL",
        "prefix": prefix,
        "planet": cfg["planet"],
        "family": cfg["family"],
        "shell_count": len(source_rows),
        "row_count": len(rows),
        "expected_row_count": expected_count,
        "first_shell": source_rows[0]["shell_id"],
        "last_shell": source_rows[-1]["shell_id"],
        "sign_numbering": {f"{i+1:02d}": sign for i, sign in enumerate(SIGNS)},
        "law": "Shell.sign uses 01-12 Aries-Pisces; first direct sign ingress begins stable ownership and retrograde recrossings remain transition metadata.",
        "failures": failures,
    }


def write_family(
    out_dir: Path,
    cfg: dict,
    source_doc: dict,
    rows: list[dict],
    audit_doc: dict,
    provenance: dict,
) -> None:
    scope = f"{rows[0]['shell_sign_id']} through {rows[-1]['shell_sign_id']}"
    doc = {
        "schema_version": "1.0.0",
        "scope": scope,
        "notation": "Shell.sign",
        "ownership": "[first_direct_ingress, next_sign_first_direct_ingress)",
        "numbering_law": "01=Aries through 12=Pisces inside each numbered temporal shell; retrograde recrossings do not renumber the segment.",
        "source_shell_table": cfg["source"],
        "source_shell_numbering_law": source_doc.get("numbering_law"),
        "provenance": provenance,
        "rows": rows,
    }
    (out_dir / f"{cfg['stem']}.json").write_text(
        json.dumps(doc, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )

    csv_rows = []
    for row in rows:
        flat = dict(row)
        flat["transition_crossings"] = json.dumps(
            flat["transition_crossings"], separators=(",", ":")
        )
        csv_rows.append(flat)
    fields = list(csv_rows[0].keys())
    with (out_dir / f"{cfg['stem']}.csv").open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(csv_rows)

    (out_dir / cfg["summary"]).write_text(
        json.dumps(audit_doc, indent=2, sort_keys=True) + "\n", encoding="utf-8"
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
    combined = {
        "status": "PASS",
        "notation": "Shell.sign",
        "law": "01=Aries through 12=Pisces; first direct sign ingress begins stable ownership and retrograde recrossings remain transition metadata.",
        "families": {},
        "failures": [],
    }
    try:
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

        for prefix in ("W", "R", "F"):
            cfg = FAMILIES[prefix]
            source_doc, source_rows = load_source(args.out_dir, cfg)
            rows = manufacture_family(swiss, prefix, cfg, source_rows)
            audit_doc = audit_family(prefix, cfg, source_rows, rows)
            combined["families"][prefix] = {
                "status": audit_doc["status"],
                "shell_count": audit_doc["shell_count"],
                "row_count": audit_doc["row_count"],
                "first_shell": audit_doc["first_shell"],
                "last_shell": audit_doc["last_shell"],
            }
            if audit_doc["status"] != "PASS":
                combined["status"] = "FAIL"
                combined["failures"].extend(
                    [f"{prefix}: {failure}" for failure in audit_doc["failures"]]
                )
            write_family(
                args.out_dir, cfg, source_doc, rows, audit_doc, provenance
            )

        (args.out_dir / "temporal-shell-sign-summary.json").write_text(
            json.dumps(combined, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
        if combined["status"] != "PASS":
            raise RuntimeError(
                "Temporal Shell.sign audit failed: " + "; ".join(combined["failures"])
            )
    finally:
        swiss.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
