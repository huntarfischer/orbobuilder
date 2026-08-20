#!/usr/bin/env python3
"""Generate official-Swiss construction data for Orbo Mundane Timespine codec 3.

The stream contains longitude/speed pairs at all position-knot times. A separate JSON
file carries exact direct/retrograde station chronology for every body. Swift Forge
keeps only the stamped positions and station data in the shipped body artifacts.
"""
from __future__ import annotations
import argparse, ctypes, hashlib, json, math
from pathlib import Path
import struct, sys

EXPECTED_SWE_VERSION = "2.10.03"
BODY_IDS = {
    "Sun":0,"Moon":1,"Mercury":2,"Venus":3,"Mars":4,"Jupiter":5,"Saturn":6,
    "Uranus":7,"Neptune":8,"Pluto":9,"True North Node":11,
}
VARIABLE_STEPS = {
    "Mercury":0.5,"Venus":1.0,"Mars":1.0,"Jupiter":1.0,"Saturn":1.0,
    "Uranus":1.0,"Neptune":1.0,"Pluto":1.0,"True North Node":0.25,
}
REQUIRED_FILES=("sepl_12.se1","semo_12.se1","sepl_18.se1","semo_18.se1")
SEFLG_SWIEPH=2; SEFLG_MOSEPH=4; SEFLG_SPEED=256

class SwissC:
    def __init__(self, library:Path, ephe_dir:Path):
        self.lib=ctypes.CDLL(str(library.resolve()))
        self.lib.swe_set_ephe_path.argtypes=[ctypes.c_char_p]; self.lib.swe_set_ephe_path.restype=None
        self.lib.swe_calc_ut.argtypes=[ctypes.c_double,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_double),ctypes.c_char_p]
        self.lib.swe_calc_ut.restype=ctypes.c_int32
        self.lib.swe_version.argtypes=[ctypes.c_char_p]; self.lib.swe_version.restype=ctypes.c_char_p
        self.lib.swe_close.argtypes=[]; self.lib.swe_close.restype=None
        buf=ctypes.create_string_buffer(256); self.lib.swe_version(buf); self.version=buf.value.decode("ascii",errors="replace")
        if self.version!=EXPECTED_SWE_VERSION: raise RuntimeError(f"Swiss C version drift: {self.version}")
        self.lib.swe_set_ephe_path(str(ephe_dir.resolve()).encode()); self.flags=SEFLG_SWIEPH|SEFLG_SPEED
    def state(self,jd:float,body_id:int)->tuple[float,float]:
        xx=(ctypes.c_double*6)(); serr=ctypes.create_string_buffer(256)
        returned=int(self.lib.swe_calc_ut(jd,body_id,self.flags,xx,serr))
        if returned<0: raise RuntimeError(f"swe_calc_ut failed at {jd}: {serr.value.decode(errors='replace')}")
        if not(returned&SEFLG_SWIEPH) or (returned&SEFLG_MOSEPH): raise RuntimeError(f"Swiss-file mode required at {jd}: flags={returned}")
        return float(xx[0]),float(xx[3])
    def close(self): self.lib.swe_close()

def sha256(path:Path)->str:
    h=hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda:f.read(1024*1024),b""): h.update(chunk)
    return h.hexdigest()

def verify_files(ephe_dir:Path)->list[dict]:
    records=[]
    for name in REQUIRED_FILES:
        path=ephe_dir/name
        if not path.is_file(): raise RuntimeError(f"Missing qualified Swiss file: {name}")
        if b"DE441" not in path.read_bytes()[:512]: raise RuntimeError(f"{name} is not DE441 generation")
        records.append({"name":name,"sha256":sha256(path),"bytes":path.stat().st_size})
    return records

def sample_count(start,end,step): return math.ceil((end-start)/step)+1

def regions(fixture,profile):
    return [
        (float(fixture["supportedStartJulianDay"]),float(fixture["denseStartJulianDay"]),float(profile["edgeSampleDays"])),
        (float(fixture["denseStartJulianDay"]),float(fixture["denseEndJulianDay"]),float(profile["coreSampleDays"])),
        (float(fixture["denseEndJulianDay"]),float(fixture["supportedEndJulianDay"]),float(profile["edgeSampleDays"])),
    ]

def motion(speed:float)->str: return "retrograde" if speed<0 else "direct"

def station_chronology(swiss:SwissC,body_name:str,body_id:int,start:float,end:float)->dict:
    _,initial_speed=swiss.state(start,body_id)
    if body_name not in VARIABLE_STEPS:
        return {"body":body_name,"initialMotion":motion(initial_speed),"stations":[]}
    step=VARIABLE_STEPS[body_name]; roots=[]; left=start; _,left_speed=swiss.state(left,body_id)
    while left+step<end:
        right=left+step; _,right_speed=swiss.state(right,body_id)
        if (left_speed<0)!=(right_speed<0):
            lo,hi,lo_speed=left,right,left_speed
            for _ in range(48):
                mid=(lo+hi)/2; _,mid_speed=swiss.state(mid,body_id)
                if (lo_speed<0)==(mid_speed<0): lo,lo_speed=mid,mid_speed
                else: hi=mid
            root=(lo+hi)/2
            if not roots or root-roots[-1][0]>1e-7:
                _,after_speed=swiss.state(min(end-1e-9,root+1e-7),body_id)
                roots.append((root,motion(after_speed)))
        left,left_speed=right,right_speed
    return {
        "body":body_name,
        "initialMotion":motion(initial_speed),
        "stations":[{"julianDay":jd,"motionAfter":after} for jd,after in roots],
    }

def main()->int:
    p=argparse.ArgumentParser()
    p.add_argument("--library",required=True);p.add_argument("--ephe-dir",required=True);p.add_argument("--fixture",required=True)
    p.add_argument("--output",required=True);p.add_argument("--stations-output",required=True);p.add_argument("--provenance-output",required=True)
    a=p.parse_args(); library=Path(a.library); ephe_dir=Path(a.ephe_dir); fixture=json.loads(Path(a.fixture).read_text())
    output=Path(a.output); stations_output=Path(a.stations_output); provenance_output=Path(a.provenance_output)
    start=float(fixture["supportedStartJulianDay"]); end=float(fixture["supportedEndJulianDay"])
    files=verify_files(ephe_dir); swiss=SwissC(library,ephe_dir)
    for jd in (start+10,2451545.0,end-10): swiss.state(jd,0); swiss.state(jd,1)

    expected=sum(sum(sample_count(x,y,s) for x,y,s in regions(fixture,profile)) for profile in fixture["profiles"])
    output.parent.mkdir(parents=True,exist_ok=True); written=0
    with output.open("wb") as out:
        for profile in fixture["profiles"]:
            name=profile["body"]; body=BODY_IDS[name]; body_written=0
            for region_start,region_end,step in regions(fixture,profile):
                count=sample_count(region_start,region_end,step)
                for i in range(count):
                    # Every knot stays on the declared cadence. When a region boundary
                    # is not cadence-aligned, the final knot intentionally lies just
                    # beyond it as a read-only interpolation guard.
                    jd=region_start+i*step
                    lon,speed=swiss.state(jd,body)
                    out.write(struct.pack("<dd",lon,speed)); written+=1; body_written+=1
            print(f"{name}: {body_written:,} position knots",flush=True)
    if written!=expected: raise RuntimeError(f"Sample count mismatch: {written} != {expected}")

    station_bodies=[]
    for profile in fixture["profiles"]:
        name=profile["body"]
        print(f"Solving stations: {name}",flush=True)
        station_bodies.append(station_chronology(swiss,name,BODY_IDS[name],start,end))
    station_document={"source":"official Swiss Ephemeris C / SEFLG_SPEED","bodies":station_bodies}
    stations_output.write_text(json.dumps(station_document,indent=2,sort_keys=True)+"\n")

    provenance={
        "astronomicalEngine":"official Swiss Ephemeris C library","swissLibraryVersion":swiss.version,
        "files":files,"flags":swiss.flags,
        "coordinateContract":{"center":"geocentric","zodiac":"tropical","frame":"ecliptic of date","position":"standard apparent Swiss Ephemeris position","speed":"SEFLG_SPEED used for construction/station solving","northNode":"true / osculating"},
        "representationCandidate":fixture["representation"],"supportedStartJulianDay":start,
        "denseStartJulianDay":fixture["denseStartJulianDay"],"denseEndJulianDay":fixture["denseEndJulianDay"],"supportedEndJulianDay":end,
        "sampleCount":written,"sampleStreamBytes":output.stat().st_size,"sampleStreamSha256":sha256(output),
        "stationCount":sum(len(b["stations"]) for b in station_bodies),"stationChronologySha256":sha256(stations_output),
    }
    provenance_output.write_text(json.dumps(provenance,indent=2,sort_keys=True)+"\n"); print(json.dumps(provenance,indent=2,sort_keys=True))
    swiss.close(); return 0

if __name__=="__main__":
    try: raise SystemExit(main())
    except Exception as exc:
        print(f"PASS 5 SWISS C SAMPLE FAILURE: {exc}",file=sys.stderr); raise
