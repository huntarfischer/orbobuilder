#!/usr/bin/env python3
"""Independently audit Orbo Mundane Timespine codec 3 against official Swiss C."""
from __future__ import annotations
import argparse, ctypes, hashlib, json, math, random, struct
from pathlib import Path
import sys

BODY_MAGIC=b"ORBTBD03";EXPECTED_CODEC=3;EXPECTED_SWE_VERSION="2.10.03"
SEFLG_SWIEPH=2;SEFLG_MOSEPH=4;SEFLG_SPEED=256
BODY_IDS={0:("Sun",0),1:("Moon",1),2:("Mercury",2),3:("Venus",3),4:("Mars",4),5:("Jupiter",5),6:("Saturn",6),7:("Uranus",7),8:("Neptune",8),9:("Pluto",9),10:("True North Node",11)}
AUDIT_FRACTIONS=(0.25,0.5,0.75)
MAX_EDGE_ANGULAR_ARCSEC=0.05;MAX_CORE_ANGULAR_ARCSEC=0.01;MAX_P999_ANGULAR_ARCSEC=0.01
MAX_SPEED_ERROR_DEG_PER_DAY=0.005;MIN_FINE_STATE_AGREEMENT=0.995;MIN_MOTION_AGREEMENT=0.99999;STATION_PROBE_MINUTES=5.0

class SwissC:
    def __init__(self,library:Path,ephe_dir:Path):
        self.lib=ctypes.CDLL(str(library.resolve()));self.lib.swe_set_ephe_path.argtypes=[ctypes.c_char_p];self.lib.swe_set_ephe_path.restype=None
        self.lib.swe_calc_ut.argtypes=[ctypes.c_double,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_double),ctypes.c_char_p];self.lib.swe_calc_ut.restype=ctypes.c_int32
        self.lib.swe_version.argtypes=[ctypes.c_char_p];self.lib.swe_version.restype=ctypes.c_char_p;self.lib.swe_close.argtypes=[];self.lib.swe_close.restype=None
        b=ctypes.create_string_buffer(256);self.lib.swe_version(b);self.version=b.value.decode("ascii",errors="replace")
        if self.version!=EXPECTED_SWE_VERSION:raise RuntimeError(f"Swiss C version drift: {self.version}")
        self.lib.swe_set_ephe_path(str(ephe_dir.resolve()).encode());self.flags=SEFLG_SWIEPH|SEFLG_SPEED
    def state(self,jd,body_id):
        xx=(ctypes.c_double*6)();serr=ctypes.create_string_buffer(256);returned=int(self.lib.swe_calc_ut(jd,body_id,self.flags,xx,serr))
        if returned<0:raise RuntimeError(f"swe_calc_ut failed at {jd}: {serr.value.decode(errors='replace')}")
        if not(returned&SEFLG_SWIEPH)or(returned&SEFLG_MOSEPH):raise RuntimeError(f"Swiss-file mode lost at {jd}: {returned}")
        return float(xx[0]),float(xx[3])
    def close(self):self.lib.swe_close()

def sha256_bytes(data):return hashlib.sha256(data).hexdigest()
def normalize360(v):
    v=math.fmod(v,360.0)
    if v<0:v+=360
    return 0.0 if v==0 else v
def wrap180(v):
    v=math.fmod(v+180.0,360.0)
    if v<0:v+=360
    return v-180
def percentile(values,q):
    if not values:return 0.0
    ordered=sorted(values);return ordered[min(len(ordered)-1,max(0,math.ceil(q*len(ordered))-1))]
def fine_state(lon):return int(math.floor(normalize360(lon)*3600.0))%1296000
def motion(speed):return "retrograde" if speed<0 else "direct"
def motion_byte(byte):
    if byte==0:return "direct"
    if byte==1:return "retrograde"
    raise RuntimeError(f"Invalid motion byte {byte}")

def parse_body(path:Path,expected_body:int):
    raw=path.read_bytes();data=memoryview(raw);off=0
    if bytes(data[:8])!=BODY_MAGIC:raise RuntimeError(f"Bad body magic: {path}")
    off=8;codec=struct.unpack_from("<H",data,off)[0];off+=2;body=data[off];off+=1;region_count=data[off];off+=1
    scale=struct.unpack_from("<I",data,off)[0];off+=4;initial=motion_byte(data[off]);off+=1;station_count=struct.unpack_from("<I",data,off)[0];off+=4
    if codec!=EXPECTED_CODEC or body!=expected_body or region_count!=3:raise RuntimeError(f"Malformed body header: {path}")
    stations=[]
    for _ in range(station_count):
        jd=struct.unpack_from("<d",data,off)[0];off+=8;after=motion_byte(data[off]);off+=1;stations.append((jd,after))
    regions=[]
    for _ in range(region_count):
        start,end,step=struct.unpack_from("<ddd",data,off);off+=24;count=struct.unpack_from("<I",data,off)[0];off+=4;sample_offset=off;byte_count=count*4
        if count<4 or off+byte_count>len(data):raise RuntimeError(f"Truncated body: {path}")
        regions.append({"start":start,"end":end,"step":step,"count":count,"offset":sample_offset});off+=byte_count
    if off!=len(data):raise RuntimeError(f"Trailing body bytes: {path}")
    return {"raw":raw,"data":data,"codec":codec,"body":body,"positionScale":scale,"initialMotion":initial,"stations":stations,"regions":regions,"bytes":len(raw),"sha256":sha256_bytes(raw)}

def sample_position(series,region,index):
    p=struct.unpack_from("<I",series["data"],region["offset"]+index*4)[0];return p/series["positionScale"]

def region_for(series,jd):
    for region in series["regions"]:
        if region["start"]<=jd<region["end"]:return region
    raise RuntimeError(f"JD {jd} outside body regions")

def expected_motion(series,jd):
    lo,hi=0,len(series["stations"])
    while lo<hi:
        mid=(lo+hi)//2
        if series["stations"][mid][0]<=jd:lo=mid+1
        else:hi=mid
    return series["initialMotion"] if lo==0 else series["stations"][lo-1][1]

def interpolate(series,jd):
    r=region_for(series,jd);x=(jd-r["start"])/r["step"];interval=math.floor(x);first=min(max(0,interval-1),r["count"]-4);indices=list(range(first,first+4))
    raw=[sample_position(series,r,i) for i in indices];positions=[raw[0]]
    for value in raw[1:]:positions.append(positions[-1]+wrap180(value-normalize360(positions[-1])))
    value=0.0;derivative=0.0
    for i,xi_raw in enumerate(indices):
        xi=float(xi_raw);basis=1.0
        for j,xj_raw in enumerate(indices):
            if j!=i:basis*=(x-float(xj_raw))/(xi-float(xj_raw))
        db=0.0
        for m,xm_raw in enumerate(indices):
            if m==i:continue
            xm=float(xm_raw);term=1.0/(xi-xm)
            for j,xj_raw in enumerate(indices):
                if j!=i and j!=m:term*=(x-float(xj_raw))/(xi-float(xj_raw))
            db+=term
        value+=positions[i]*basis;derivative+=positions[i]*db
    speed=abs(derivative/r["step"])
    if expected_motion(series,jd)=="retrograde":speed=-speed
    return normalize360(value),speed

def audit_body(series,body,body_id,swiss,dense_start,dense_end):
    angular=[];speeds=[];core=[];edge=[];fine_matches=motion_matches=total=0;worst=None
    def check(jd):
        nonlocal fine_matches,motion_matches,total,worst
        ref_lon,ref_speed=swiss.state(jd,body_id);spine_lon,spine_speed=interpolate(series,jd);err=abs(wrap180(spine_lon-ref_lon))*3600.0;se=abs(spine_speed-ref_speed)
        angular.append(err);speeds.append(se);total+=1;(core if dense_start<=jd<dense_end else edge).append(err)
        fine_matches+=fine_state(spine_lon)==fine_state(ref_lon);motion_matches+=motion(spine_speed)==motion(ref_speed)
        if worst is None or err>worst["angularArcseconds"]:worst={"julianDay":jd,"angularArcseconds":err,"referenceLongitude":ref_lon,"timespineLongitude":spine_lon,"referenceSpeed":ref_speed,"timespineSpeed":spine_speed}
    for r in series["regions"]:
        for interval in range(r["count"]-1):
            t0=r["start"]+interval*r["step"];t1=min(t0+r["step"],r["end"])
            for f in AUDIT_FRACTIONS:check(t0+(t1-t0)*f)
    rng=random.Random(0x4F52424F+body);start=series["regions"][0]["start"];end=series["regions"][-1]["end"]
    for _ in range(5000):check(start+rng.random()*(end-start))
    return {"bodyBytes":series["bytes"],"stationCount":len(series["stations"]),"auditPoints":total,"maxAngularArcseconds":max(angular,default=0),"maxCoreAngularArcseconds":max(core,default=0),"maxEdgeAngularArcseconds":max(edge,default=0),"p999AngularArcseconds":percentile(angular,.999),"p99AngularArcseconds":percentile(angular,.99),"maxSpeedErrorDegreesPerDay":max(speeds,default=0),"p999SpeedErrorDegreesPerDay":percentile(speeds,.999),"fineStateAgreement":fine_matches/total if total else 1,"motionAgreement":motion_matches/total if total else 1,"regions":[{"sampleDays":r["step"],"samples":r["count"]}for r in series["regions"]],"worstAngularPoint":worst}

def audit_stations(series,body_id,swiss):
    delta=STATION_PROBE_MINUTES/1440.0;start=series["regions"][0]["start"];end=series["regions"][-1]["end"];mismatches=[]
    for root,_ in series["stations"]:
        for side,jd in (("before",root-delta),("after",root+delta)):
            if not(start<=jd<end):continue
            _,ref_speed=swiss.state(jd,body_id);_,spine_speed=interpolate(series,jd)
            if motion(ref_speed)!=motion(spine_speed):mismatches.append({"stationJulianDay":root,"probe":side,"probeJulianDay":jd,"referenceSpeed":ref_speed,"timespineSpeed":spine_speed})
    return {"stationCount":len(series["stations"]),"probeMinutes":STATION_PROBE_MINUTES,"motionMismatches":len(mismatches),"firstMismatches":mismatches[:20]}

def main():
    p=argparse.ArgumentParser();p.add_argument("--library",required=True);p.add_argument("--ephe-dir",required=True);p.add_argument("--artifact-dir",required=True);p.add_argument("--provenance",required=True);p.add_argument("--report",required=True);a=p.parse_args()
    swiss=SwissC(Path(a.library),Path(a.ephe_dir));artifact_dir=Path(a.artifact_dir);manifest_raw=(artifact_dir/"mundane-timespine-v1.json").read_bytes();manifest=json.loads(manifest_raw)
    if manifest["codec"]!=EXPECTED_CODEC:raise RuntimeError("Wrong Timespine codec")
    dense_start=float(manifest["denseStartJulianDay"]);dense_end=float(manifest["denseEndJulianDay"]);series_by_body={}
    for body,rec in enumerate(manifest["bodies"]):
        s=parse_body(artifact_dir/rec["file"],body)
        if s["sha256"]!=rec["sha256"] or s["bytes"]!=rec["bytes"] or len(s["stations"])!=rec["stationCount"]:raise RuntimeError(f"Manifest/body identity mismatch for {rec['body']}")
        series_by_body[body]=s
    body_reports={};station_reports={};failures=[]
    for body,(name,body_id) in BODY_IDS.items():
        print(f"Auditing {name} codec 3...",flush=True);r=audit_body(series_by_body[body],body,body_id,swiss,dense_start,dense_end);body_reports[name]=r
        if r["maxEdgeAngularArcseconds"]>MAX_EDGE_ANGULAR_ARCSEC:failures.append(f"{name} edge max {r['maxEdgeAngularArcseconds']:.9f} arcsec")
        if r["maxCoreAngularArcseconds"]>MAX_CORE_ANGULAR_ARCSEC:failures.append(f"{name} core max {r['maxCoreAngularArcseconds']:.9f} arcsec")
        if r["p999AngularArcseconds"]>MAX_P999_ANGULAR_ARCSEC:failures.append(f"{name} p99.9 {r['p999AngularArcseconds']:.9f} arcsec")
        if r["maxSpeedErrorDegreesPerDay"]>MAX_SPEED_ERROR_DEG_PER_DAY:failures.append(f"{name} speed max {r['maxSpeedErrorDegreesPerDay']:.9g} deg/day")
        if r["fineStateAgreement"]<MIN_FINE_STATE_AGREEMENT:failures.append(f"{name} RingFineState agreement {r['fineStateAgreement']:.9%}")
        if r["motionAgreement"]<MIN_MOTION_AGREEMENT:failures.append(f"{name} motion agreement {r['motionAgreement']:.9%}")
        if series_by_body[body]["stations"]:
            station=audit_stations(series_by_body[body],body_id,swiss);station_reports[name]=station
            if station["motionMismatches"]:failures.append(f"{name} has {station['motionMismatches']} station-direction mismatches at +/- {STATION_PROBE_MINUTES:g} minutes")
    provenance=json.loads(Path(a.provenance).read_text());body_bytes=sum(s["bytes"] for s in series_by_body.values())
    result={"status":"PASS" if not failures else "FAIL","artifact":{"version":manifest["version"],"codec":manifest["codec"],"astroDNACodec":manifest["astroDNACodec"],"representation":manifest["representation"],"manifestBytes":len(manifest_raw),"manifestSha256":sha256_bytes(manifest_raw),"bodyBytes":body_bytes,"totalBytes":body_bytes+len(manifest_raw),"supportedStartJulianDay":manifest["supportedStartJulianDay"],"denseStartJulianDay":dense_start,"denseEndJulianDay":dense_end,"supportedEndJulianDay":manifest["supportedEndJulianDay"]},"thresholds":{"maxEdgeAngularArcseconds":MAX_EDGE_ANGULAR_ARCSEC,"maxCoreAngularArcseconds":MAX_CORE_ANGULAR_ARCSEC,"maxP999AngularArcseconds":MAX_P999_ANGULAR_ARCSEC,"maxSpeedErrorDegreesPerDay":MAX_SPEED_ERROR_DEG_PER_DAY,"minimumFineStateAgreement":MIN_FINE_STATE_AGREEMENT,"minimumMotionAgreement":MIN_MOTION_AGREEMENT,"stationProbeMinutes":STATION_PROBE_MINUTES},"bodies":body_reports,"stations":station_reports,"sourceProvenance":provenance,"failures":failures}
    Path(a.report).write_text(json.dumps(result,indent=2,sort_keys=True)+"\n");print(json.dumps(result,indent=2,sort_keys=True));swiss.close()
    if failures:
        print("PASS 5 QUALIFICATION FAILED",file=sys.stderr)
        for f in failures:print(f"  - {f}",file=sys.stderr)
        return 1
    print("PASS 5 QUALIFICATION PASSED");return 0
if __name__=="__main__":raise SystemExit(main())
