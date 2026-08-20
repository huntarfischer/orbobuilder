#!/usr/bin/env python3
"""Canonical wrapper for temporal-shell manufacture.

Adds the full long-range lunar DE441 dependency set required by Swiss C and scans one
transition-cluster before Z0 so a post-Z0 recrossing from a pre-Z0 cycle can never be
misnumbered W0/R0/F0.
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate_temporal_shell_tables as base

base.REQUIRED_EPHE_FILES = base.REQUIRED_EPHE_FILES + (
    "semom36.se1", "semom30.se1", "semom24.se1", "semom18.se1", "semom12.se1", "semom06.se1",
    "semo_00.se1", "semo_06.se1", "semo_12.se1", "semo_18.se1", "semo_24.se1",
)


def manufacture_family(swiss, prefix, cfg, scan_end):
    scan_start = base.Z0_JD - cfg["cluster_gap"]
    crossings = base.all_zero_crossings(swiss, cfg["body"], scan_start, scan_end, cfg["step"])
    clusters = base.cluster_crossings(crossings, cfg["cluster_gap"])
    qualifying = []
    for cluster in clusters:
        directs = [c for c in cluster if c["motion"] == "direct"]
        if not directs:
            continue
        first = directs[0]
        # Discard the entire transition cluster if its initial ingress belongs to
        # the pre-Z0 cycle, even when one of its later direct recrossings is post-Z0.
        if first["jd_ut"] <= base.Z0_JD:
            continue
        final = directs[-1]
        transition = [
            c for c in cluster
            if first["jd_ut"] - 1e-7 <= c["jd_ut"] <= final["jd_ut"] + 1e-7
        ]
        qualifying.append((first, final, transition))

    rows = []
    for ordinal in range(len(qualifying) - 1):
        first, final, transition = qualifying[ordinal]
        next_first = qualifying[ordinal + 1][0]
        if first["jd_ut"] >= base.Z_BOUNDS["Z23"][1]:
            break
        pre_jd, pre_utc, floor = base.transition_shadow(
            swiss, cfg["body"], first["jd_ut"], final["jd_ut"]
        )
        rows.append({
            "shell_id": f"{prefix}{ordinal}",
            "ordinal": ordinal,
            "planet": cfg["planet"],
            "family": cfg["family"],
            "pre_shadow_start_jd_ut": pre_jd,
            "pre_shadow_start_utc": pre_utc,
            "pre_shadow_floor_degree": floor,
            "first_aries_ingress_jd_ut": first["jd_ut"],
            "first_aries_ingress_utc": first["utc"],
            "final_pisces_egress_jd_ut": final["jd_ut"],
            "final_pisces_egress_utc": final["utc"],
            "next_shell_first_aries_ingress_jd_ut": next_first["jd_ut"],
            "next_shell_first_aries_ingress_utc": next_first["utc"],
            "transition_crossings": transition,
            "transition_crossing_count": len(transition),
            "z21_z23_intersections": base.z_intersections(first["jd_ut"], next_first["jd_ut"]),
        })
    if not rows or rows[0]["ordinal"] != 0:
        raise RuntimeError(f"{prefix}0 was not manufactured")
    return rows


base.manufacture_family = manufacture_family

if __name__ == "__main__":
    raise SystemExit(base.main())
