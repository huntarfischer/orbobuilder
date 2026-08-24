#!/usr/bin/env python3
"""Manufacture Orbo's Z21-Z23 Auxiliary Seam crossing substrate.

Reuses Pass 5's pinned Swiss C gateway and emits only celestial matter:
position crossings, exact stations, retrograde crossings, audits, and provenance.
Core marker selection and native Timespine adoption are deliberately later work.
"""
from __future__ import annotations

import argparse
import csv
import gzip
import io
import json
import math
from dataclasses import dataclass
from pathlib import Path

import generate_temporal_shell_tables as base

Z21_START = 2297171.740867775
Z22_START = 2386637.0793997087
Z23_START = 2475819.1417904533
Z23_END = 2565295.0945935287
SECONDS_PER_DAY = 86400.0
Z_BOUNDS = {
    "Z21": (Z21_START, Z22_START),
    "Z22": (Z22_START, Z23_START),
    "Z23": (Z23_START, Z23_END),
}

SE_MEAN_APOG = 12
SE_OSCU_APOG = 13
SE_CHIRON = 15
SE_CERES = 17
SE_PALLAS = 18
SE_JUNO = 19
SE_VESTA = 20
SE_AST_OFFSET = 10000

DE441_FILES = (
    "sepl_12.se1", "sepl_18.se1",
    "semo_12.se1", "semo_18.se1",
    "seas_12.se1", "seas_18.se1",
)
ERIS_FILE = "ast136/s136199.se1"


@dataclass(frozen=True)
class Track:
    name: str
    body: int
    resolution: float
    step_days: float
    source_class: str
    canonical: bool
    companion_of: str | None = None


TRACKS = {
    "TrueBML": Track("TrueBML", SE_OSCU_APOG, 1.0, 0.05, "lunar osculating apogee", True),
    "MeanBML": Track("MeanBML", SE_MEAN_APOG, 0.1, 2.0, "analytic mean lunar apogee", False, "TrueBML"),
    "Chiron": Track("Chiron", SE_CHIRON, 0.1, 0.50, "centaur", True),
    "Ceres": Track("Ceres", SE_CERES, 1.0, 0.20, "main asteroid / dwarf planet", True),
    "Pallas": Track("Pallas", SE_PALLAS, 1.0, 0.20, "main asteroid", True),
    "Juno": Track("Juno", SE_JUNO, 1.0, 0.20, "main asteroid", True),
    "Vesta": Track("Vesta", SE_VESTA, 1.0, 0.20, "main asteroid", True),
    "Eris": Track("Eris", SE_AST_OFFSET + 136199, 0.1, 1.0, "numbered dwarf planet", True),
}


@dataclass
class Crossing:
    jd: float
    tick: int
    direction: int


@dataclass
class Station:
    jd: float
    longitude: float
    before: int
    after: int


def norm(x: float) -> float:
    return x % 360.0


def sdelta(a: float, b: float) -> float:
    d = norm(b) - norm(a)
    if d > 180.0:
        d -= 360.0
    if d < -180.0:
        d += 360.0
    return d


def direction_name(d: int) -> str:
    return "increasing" if d >= 0 else "decreasing"


def z_of(jd: float) -> str:
    for z, (a, b) in Z_BOUNDS.items():
        if a <= jd < b:
            return z
    raise RuntimeError(f"JD outside Z21-Z23: {jd}")


def verify_sources(ephe_dir: Path, require_eris: bool) -> list[dict]:
    records = []
    for rel in DE441_FILES:
        p = ephe_dir / rel
        if not p.is_file():
            raise RuntimeError(f"Missing required DE441 file: {rel}")
        head = p.read_bytes()[:512]
        if b"DE441" not in head:
            raise RuntimeError(f"Non-DE441 main ephemeris rejected: {rel}")
        records.append({
            "path": rel,
            "sourceClass": "Swiss main ephemeris, DE441 generation",
            "bytes": p.stat().st_size,
            "sha256": base.sha256(p),
        })
    if require_eris:
        eris = ephe_dir / ERIS_FILE
        if not eris.is_file():
            raise RuntimeError(f"Missing long-range Eris file: {ERIS_FILE}")
        head = eris.read_bytes()[:512]
        if b"SWISSEPH" not in head:
            raise RuntimeError(f"Invalid Swiss Eris file header: {ERIS_FILE}")
        if b"DE441" not in head:
            raise RuntimeError(f"Non-DE441 Eris ephemeris rejected: {ERIS_FILE}")
        records.append({
            "path": ERIS_FILE,
            "sourceClass": "Swiss long-range numbered asteroid ephemeris, DE441 generation",
            "bytes": eris.stat().st_size,
            "sha256": base.sha256(eris),
        })
    return records


def state(swiss: base.SwissC, track: Track, jd: float) -> tuple[float, float]:
    lon, speed = swiss.state(jd, track.body)
    return norm(lon), speed


def refine_station(swiss: base.SwissC, track: Track, lo: float, hi: float) -> float:
    """Solve speed=0 inside a sign-changing bracket without surrendering the bracket.

    Plain midpoint bisection gives excellent time accuracy, but for very slow bodies the
    Swiss speed value can leave a few 1e-8 deg/day of residual at the returned midpoint.
    Use a safeguarded secant estimate inside the bracket, retain the sign-changing bracket,
    and return the evaluated point with the smallest absolute speed.
    """
    a, b = lo, hi
    _, fa = state(swiss, track, a)
    _, fb = state(swiss, track, b)
    if fa == 0.0:
        return a
    if fb == 0.0:
        return b
    if fa * fb > 0.0:
        raise RuntimeError(f"Station not bracketed for {track.name}: {lo}..{hi}")

    best_jd, best_abs = (a, abs(fa)) if abs(fa) <= abs(fb) else (b, abs(fb))
    for _ in range(80):
        denom = fb - fa
        x = (a * fb - b * fa) / denom if abs(denom) > 1e-30 else (a + b) / 2.0
        if not (a < x < b):
            x = (a + b) / 2.0
        _, fx = state(swiss, track, x)
        if abs(fx) < best_abs:
            best_jd, best_abs = x, abs(fx)
        if fx == 0.0:
            return x
        if fa * fx <= 0.0:
            b, fb = x, fx
        else:
            a, fa = x, fx

        # Regula falsi can cling to one edge on curved functions. Force a midpoint
        # contraction periodically while preserving the sign-changing bracket.
        if _ % 4 == 3:
            m = (a + b) / 2.0
            if m == a or m == b:
                break
            _, fm = state(swiss, track, m)
            if abs(fm) < best_abs:
                best_jd, best_abs = m, abs(fm)
            if fm == 0.0:
                return m
            if fa * fm <= 0.0:
                b, fb = m, fm
            else:
                a, fa = m, fm

        if math.nextafter(a, b) >= b:
            break

    # Check the final bracket endpoints and midpoint explicitly because one of those
    # representable Julian days can be better than the last secant proposal.
    candidates = [best_jd, a, b]
    m = (a + b) / 2.0
    if a <= m <= b:
        candidates.append(m)
    scored = []
    for jd in candidates:
        _, speed = state(swiss, track, jd)
        scored.append((abs(speed), jd))
    return min(scored)[1]


def refine_crossing(
    swiss: base.SwissC,
    track: Track,
    target_u: float,
    lo: float,
    hi: float,
    anchor_lon: float,
    anchor_u: float,
) -> float:
    def value(jd: float) -> tuple[float, float]:
        lon, speed = state(swiss, track, jd)
        return anchor_u + sdelta(anchor_lon, lon) - target_u, speed

    a, b = lo, hi
    fa, _ = value(a)
    fb, _ = value(b)
    if abs(fa) < 1e-12:
        return a
    if abs(fb) < 1e-12:
        return b
    if fa * fb > 0.0:
        raise RuntimeError(f"Crossing not bracketed for {track.name}: {lo}..{hi}")

    x = a + (b - a) * abs(fa) / max(1e-18, abs(fa) + abs(fb))
    for _ in range(10):
        fx, speed = value(x)
        if abs(fx) < 1e-11:
            return x
        if fa * fx <= 0.0:
            b, fb = x, fx
        else:
            a, fa = x, fx
        nx = x - fx / speed if abs(speed) > 1e-10 else (a + b) / 2.0
        x = nx if a < nx < b else (a + b) / 2.0
    for _ in range(40):
        m = (a + b) / 2.0
        fm, _ = value(m)
        if abs(fm) < 1e-12:
            return m
        if fa * fm <= 0.0:
            b = m
        else:
            a, fa = m, fm
    return (a + b) / 2.0


def emit_monotonic(
    swiss: base.SwissC,
    track: Track,
    lo: float,
    hi: float,
    lo_lon: float,
    hi_lon: float,
    out: list[Crossing],
) -> None:
    lo_u = lo_lon
    hi_u = lo_u + sdelta(lo_lon, hi_lon)
    delta = hi_u - lo_u
    if abs(delta) < 1e-14:
        return
    direction = 1 if delta > 0.0 else -1
    res = track.resolution
    modulus = int(round(360.0 / res))
    if direction > 0:
        first, last = math.floor(lo_u / res) + 1, math.floor(hi_u / res)
        ks = range(first, last + 1) if first <= last else ()
    else:
        first, last = math.ceil(lo_u / res) - 1, math.ceil(hi_u / res)
        ks = range(first, last - 1, -1) if first >= last else ()
    for k in ks:
        jd = refine_crossing(swiss, track, k * res, lo, hi, lo_lon, lo_u)
        if Z21_START - 1e-9 <= jd < Z23_END - 1e-9:
            tick = int(k) % modulus
            if not out or out[-1].tick != tick or abs(out[-1].jd - jd) * SECONDS_PER_DAY >= 0.25:
                out.append(Crossing(jd, tick, direction))


def generate(swiss: base.SwissC, track: Track) -> tuple[list[Crossing], list[Station]]:
    crossings: list[Crossing] = []
    stations: list[Station] = []
    lo = Z21_START
    lo_lon, lo_speed = state(swiss, track, lo)
    while lo < Z23_END:
        hi = min(lo + track.step_days, Z23_END)
        hi_lon, hi_speed = state(swiss, track, hi)
        if lo_speed * hi_speed < 0.0:
            sjd = refine_station(swiss, track, lo, hi)
            slon, _ = state(swiss, track, sjd)
            before = 1 if lo_speed >= 0.0 else -1
            after = 1 if hi_speed >= 0.0 else -1
            if not stations or abs(stations[-1].jd - sjd) * SECONDS_PER_DAY >= 1.0:
                stations.append(Station(sjd, slon, before, after))
            if sjd - lo > 1e-10:
                emit_monotonic(swiss, track, lo, sjd, lo_lon, slon, crossings)
            if hi - sjd > 1e-10:
                emit_monotonic(swiss, track, sjd, hi, slon, hi_lon, crossings)
        else:
            emit_monotonic(swiss, track, lo, hi, lo_lon, hi_lon, crossings)
        lo, lo_lon, lo_speed = hi, hi_lon, hi_speed
    crossings.sort(key=lambda x: x.jd)
    stations.sort(key=lambda x: x.jd)
    return crossings, stations


def write_gzip_csv(path: Path, header: list[str], rows) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("wb") as raw:
        with gzip.GzipFile(fileobj=raw, mode="wb", mtime=0) as gz:
            with io.TextIOWrapper(gz, encoding="utf-8", newline="") as f:
                w = csv.writer(f, lineterminator="\n")
                w.writerow(header)
                w.writerows(rows)


def audit(swiss: base.SwissC, track: Track, crossings: list[Crossing], stations: list[Station]) -> dict:
    if not crossings:
        raise RuntimeError(f"{track.name}: no crossings")
    if any(crossings[i].jd <= crossings[i - 1].jd for i in range(1, len(crossings))):
        raise RuntimeError(f"{track.name}: crossings not strictly increasing")
    if any(stations[i].jd <= stations[i - 1].jd for i in range(1, len(stations))):
        raise RuntimeError(f"{track.name}: stations not strictly increasing")

    idx = sorted(set([0, len(crossings) - 1] + [round((len(crossings) - 1) * q / 24) for q in range(25)]))
    max_crossing_error = 0.0
    for i in idx:
        c = crossings[i]
        lon, _ = state(swiss, track, c.jd)
        target = c.tick * track.resolution
        max_crossing_error = max(max_crossing_error, abs(sdelta(target, lon)))
    if max_crossing_error > 1e-7:
        raise RuntimeError(f"{track.name}: crossing residual {max_crossing_error}")

    station_sample = stations if len(stations) <= 50 else [stations[round((len(stations) - 1) * q / 49)] for q in range(50)]
    max_station_speed = 0.0
    for s in station_sample:
        _, speed = state(swiss, track, s.jd)
        max_station_speed = max(max_station_speed, abs(speed))
    if max_station_speed > 1e-8:
        raise RuntimeError(f"{track.name}: station residual {max_station_speed}")

    by_z = {z: 0 for z in Z_BOUNDS}
    for c in crossings:
        by_z[z_of(c.jd)] += 1
    return {
        "status": "PASS",
        "body": track.name,
        "resolutionDegrees": track.resolution,
        "crossingCount": len(crossings),
        "stationCount": len(stations),
        "retrogradeCrossingCount": sum(c.direction < 0 for c in crossings),
        "crossingsByZeitgeist": by_z,
        "sampledMaxCrossingResidualDegrees": max_crossing_error,
        "sampledMaxStationSpeedDegreesPerDay": max_station_speed,
    }


def forge(swiss: base.SwissC, track: Track, outdir: Path) -> dict:
    crossings, stations = generate(swiss, track)
    result = audit(swiss, track, crossings, stations)
    res = track.resolution
    cp = outdir / "crossings" / f"{track.name}.csv.gz"
    sp = outdir / "stations" / f"{track.name}.csv.gz"
    rp = outdir / "retrograde-crossings" / f"{track.name}.csv.gz"
    ap = outdir / "audits" / f"{track.name}.json"

    write_gzip_csv(cp,
        ["body", "focalCelestialTick", "focalCelestialDegrees", "celestialResolutionDegrees", "zeitgeist", "utJulianDay", "utOffsetSecondsFromZ21Start", "sequenceDirection"],
        ([track.name, c.tick, f"{c.tick * res:.1f}", f"{res:g}", z_of(c.jd), f"{c.jd:.12f}", int(round((c.jd - Z21_START) * SECONDS_PER_DAY)), direction_name(c.direction)] for c in crossings))
    write_gzip_csv(sp,
        ["body", "zeitgeist", "utJulianDay", "utOffsetSecondsFromZ21Start", "longitudeDegrees", "beforeDirection", "afterDirection"],
        ([track.name, z_of(s.jd), f"{s.jd:.12f}", int(round((s.jd - Z21_START) * SECONDS_PER_DAY)), f"{s.longitude:.9f}", direction_name(s.before), direction_name(s.after)] for s in stations))
    write_gzip_csv(rp,
        ["body", "focalCelestialTick", "zeitgeist", "utJulianDay", "utOffsetSecondsFromZ21Start"],
        ([track.name, c.tick, z_of(c.jd), f"{c.jd:.12f}", int(round((c.jd - Z21_START) * SECONDS_PER_DAY))] for c in crossings if c.direction < 0))
    ap.parent.mkdir(parents=True, exist_ok=True)
    ap.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")

    result.update({
        "canonical": track.canonical,
        "companionOf": track.companion_of,
        "sourceClass": track.source_class,
        "files": {str(p.relative_to(outdir)): {"bytes": p.stat().st_size, "sha256": base.sha256(p)} for p in (cp, sp, rp, ap)},
    })
    return result


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--library", type=Path, required=True)
    p.add_argument("--ephe-dir", type=Path, required=True)
    p.add_argument("--output-dir", type=Path, required=True)
    p.add_argument("--source-commit", required=True)
    p.add_argument("--body", action="append", choices=sorted(TRACKS))
    args = p.parse_args()

    selected = args.body or list(TRACKS)
    sources = verify_sources(args.ephe_dir, require_eris="Eris" in selected)
    swiss = base.SwissC(args.library, args.ephe_dir)
    try:
        args.output_dir.mkdir(parents=True, exist_ok=True)
        tables = []
        for name in selected:
            print(f"FORGE {name}", flush=True)
            tables.append(forge(swiss, TRACKS[name], args.output_dir))
        summary = {
            "status": "PASS",
            "span": "Z21-Z23",
            "startJDUT": Z21_START,
            "z22StartJDUT": Z22_START,
            "z23StartJDUT": Z23_START,
            "endJDUT": Z23_END,
            "swissVersion": swiss.version,
            "swissSourceCommit": args.source_commit,
            "coordinateContract": "geocentric tropical apparent ecliptic longitude; UT",
            "flagsContract": "SWIEPH|SPEED; Moshier fallback fatal",
            "sourceFiles": sources,
            "tables": tables,
        }
        (args.output_dir / "summary.json").write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n")
        print(json.dumps(summary, indent=2, sort_keys=True))
    finally:
        swiss.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
