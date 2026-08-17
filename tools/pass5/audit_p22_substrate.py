#!/usr/bin/env python3
import csv, gzip, json, math, statistics
from pathlib import Path

ROOT = Path(__file__).resolve().parent / "p22-data"
OUT = Path(__file__).resolve().parent / "p22-results" / "substrate-audit.json"
COMPACT = Path(__file__).resolve().parent / "p22-results" / "substrate-audit-compact.json"


def percentile(xs, p):
    if not xs:
        return None
    ys = sorted(xs)
    if len(ys) == 1:
        return ys[0]
    k = (len(ys)-1) * p
    f = math.floor(k); c = math.ceil(k)
    if f == c:
        return ys[int(k)]
    return ys[f] * (c-k) + ys[c] * (k-f)


def collision_stats(keys):
    counts = {}
    for k in keys:
        counts[k] = counts.get(k, 0) + 1
    reps = [n for n in counts.values() if n > 1]
    return {
        "repeatedKeys": len(reps),
        "repeatedRows": sum(reps),
        "collisionExcess": sum(n-1 for n in reps),
        "unique": not reps,
    }

summary = json.loads((ROOT / "summary.json").read_text())
manifest = json.loads((ROOT / "manifest.json").read_text())
by_body_summary = {x["body"]: x for x in summary["bodyTables"]}
manifest_sizes = {Path(x["path"]).name: x for x in manifest["files"]}

result = {
    "span": summary["spanName"],
    "durationYears": summary["durationYears"],
    "purpose": "Read-only audit of persisted P22 body tables for resolution spacing, marker uniqueness, and coarsening behavior.",
    "bodies": [],
}

for path in sorted((ROOT / "body-tables").glob("*.csv.gz")):
    body = path.name.removesuffix(".csv.gz")
    s = by_body_summary[body]
    rows = []
    with gzip.open(path, "rt", newline="") as f:
        r = csv.DictReader(f)
        marker_cols = [c for c in r.fieldnames if c.endswith("Degree") and c not in {"focalCelestialDegrees", "celestialResolutionDegrees"}]
        for row in r:
            rows.append((
                int(row["focalCelestialTick"]),
                int(row["utOffsetSeconds"]),
                row["sequenceDirection"],
                tuple(int(row[c]) for c in marker_cols),
            ))
    gaps_hours = [(rows[i][1]-rows[i-1][1])/3600 for i in range(1, len(rows)) if rows[i][1] > rows[i-1][1]]
    tick_counts = {}
    for tick, *_ in rows:
        tick_counts[tick] = tick_counts.get(tick, 0) + 1
    current_keys = [(r[0],) + r[3] for r in rows]
    current_collision = collision_stats(current_keys)
    sun_collision = None
    if "SunDegree" in marker_cols:
        sun_idx = marker_cols.index("SunDegree")
        sun_collision = collision_stats([(r[0], r[3][sun_idx]) for r in rows])

    resolution = float(s["selectedResolutionDegrees"])
    coarsening = []
    if abs(resolution - 0.1) < 1e-9:
        for target, factor in [(0.2,2),(0.5,5),(1.0,10)]:
            kept = [r for r in rows if r[0] % factor == 0]
            keys = [(r[0]//factor,) + r[3] for r in kept]
            item = {
                "resolutionDegrees": target,
                "records": len(kept),
                "currentMarkerSetCollision": collision_stats(keys),
            }
            if "SunDegree" in marker_cols:
                sun_idx = marker_cols.index("SunDegree")
                item["sunAloneCollision"] = collision_stats([(r[0]//factor, r[3][sun_idx]) for r in kept])
            if len(kept) > 1:
                gh = [(kept[i][1]-kept[i-1][1])/3600 for i in range(1,len(kept)) if kept[i][1] > kept[i-1][1]]
                item["gapHours"] = {
                    "median": percentile(gh, .5), "p90": percentile(gh,.9), "p99": percentile(gh,.99), "max": max(gh) if gh else None
                }
            coarsening.append(item)

    mf = manifest_sizes[path.name]
    result["bodies"].append({
        "body": body,
        "resolutionDegrees": resolution,
        "records": len(rows),
        "markerColumns": marker_cols,
        "markerCount": len(marker_cols),
        "currentMarkerCollision": current_collision,
        "sunAloneCollision": sun_collision,
        "gapHours": {
            "median": percentile(gaps_hours,.5),
            "p90": percentile(gaps_hours,.9),
            "p99": percentile(gaps_hours,.99),
            "max": max(gaps_hours) if gaps_hours else None,
        },
        "occurrencesPerCelestialTick": {
            "mean": statistics.fmean(tick_counts.values()),
            "median": statistics.median(tick_counts.values()),
            "max": max(tick_counts.values()),
        },
        "directionRows": {
            "increasing": sum(1 for r in rows if r[2] == "increasing"),
            "decreasing": sum(1 for r in rows if r[2] == "decreasing"),
        },
        "candidatePackedBytes": s["candidatePackedBytes"],
        "persistedCompressedBytes": mf["compressedBytes"],
        "coarsening": coarsening,
    })

result["totals"] = {
    "records": sum(b["records"] for b in result["bodies"]),
    "candidatePackedBytes": sum(b["candidatePackedBytes"] for b in result["bodies"]),
    "persistedBodyCompressedBytes": sum(b["persistedCompressedBytes"] for b in result["bodies"]),
}
OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")

compact = {
    "span": result["span"],
    "bodies": []
}
for b in result["bodies"]:
    compact["bodies"].append({
        "body": b["body"],
        "resolution": b["resolutionDegrees"],
        "records": b["records"],
        "markers": [x.removesuffix("Degree") for x in b["markerColumns"]],
        "markerUnique": b["currentMarkerCollision"]["unique"],
        "sunRepeatedKeys": None if b["sunAloneCollision"] is None else b["sunAloneCollision"]["repeatedKeys"],
        "gapMedianHours": round(b["gapHours"]["median"], 3),
        "gapP90Hours": round(b["gapHours"]["p90"], 3),
        "gapP99Hours": round(b["gapHours"]["p99"], 3),
        "gapMaxHours": round(b["gapHours"]["max"], 3),
        "packedBytes": b["candidatePackedBytes"],
        "coarsening": [
            {
                "resolution": x["resolutionDegrees"],
                "records": x["records"],
                "markerUnique": x["currentMarkerSetCollision"]["unique"],
                "sunRepeatedKeys": None if "sunAloneCollision" not in x else x["sunAloneCollision"]["repeatedKeys"],
                "gapMedianHours": round(x["gapHours"]["median"], 3),
                "gapP99Hours": round(x["gapHours"]["p99"], 3),
                "gapMaxHours": round(x["gapHours"]["max"], 3),
            }
            for x in b["coarsening"]
        ]
    })
COMPACT.write_text(json.dumps(compact, indent=2) + "\n")
print(json.dumps(compact, indent=2))
