#!/usr/bin/env python3
import argparse, ctypes, csv, gzip, itertools, json, math, os, hashlib
from pathlib import Path

SECONDS_PER_DAY = 86400.0
SEFLG_SWIEPH = 2
SEFLG_MOSEPH = 4
SEFLG_SPEED = 256
BODIES = [
    ("Sun",0,1.0,0.20),("Moon",1,1.0,0.05),("Mercury",2,1.0,0.10),
    ("Venus",3,1.0,0.20),("Mars",4,1.0,0.25),("Jupiter",5,0.1,0.25),
    ("Saturn",6,0.1,0.50),("Uranus",7,0.1,1.0),("Neptune",8,0.1,1.0),
    ("Pluto",9,0.1,1.0),("NorthNode",11,0.1,0.10)
]
BODY_BY_NAME = {x[0]:x for x in BODIES}
MARKER_PRIORITY = ["Sun","Pluto","Neptune","Uranus","Saturn","Jupiter","NorthNode","Mars","Venus","Mercury","Moon"]
SPANS = {
    "Z21": (2297171.740867775, 2386637.0793997087, "1577-05-05T05:46:50.976Z", "1822-04-16T13:54:20.135Z"),
    "Z23": (2475819.1417904533, 2565295.0945935287, "2066-06-17T15:24:10.695Z", "2311-06-10T14:16:12.881Z"),
}

def norm(x): return x % 360.0

def delta(a,b):
    d=norm(b)-norm(a)
    if d>180: d-=360
    if d<-180: d+=360
    return d

def imod(v,m): return v % m

class Swiss:
    def __init__(self, libpath, ephe):
        self.lib=ctypes.CDLL(libpath)
        self.lib.swe_set_ephe_path.argtypes=[ctypes.c_char_p]
        self.lib.swe_calc_ut.argtypes=[ctypes.c_double,ctypes.c_int,ctypes.c_int,ctypes.POINTER(ctypes.c_double),ctypes.c_char_p]
        self.lib.swe_calc_ut.restype=ctypes.c_int
        self.lib.swe_version.argtypes=[ctypes.c_char_p]
        self.lib.swe_version.restype=ctypes.c_char_p
        self.lib.swe_set_ephe_path(str(ephe).encode())
        b=ctypes.create_string_buffer(128); self.lib.swe_version(b); self.version=b.value.decode()
    def state(self, body, jd):
        xx=(ctypes.c_double*6)(); err=ctypes.create_string_buffer(256)
        r=self.lib.swe_calc_ut(jd,body,SEFLG_SWIEPH|SEFLG_SPEED,xx,err)
        if r<0 or not (r&SEFLG_SWIEPH) or (r&SEFLG_MOSEPH):
            raise RuntimeError(f"Swiss failure body={body} jd={jd}: {err.value.decode(errors='replace')}")
        return norm(xx[0]),xx[3]

def refine_station(sw,body,lo,hi):
    flo=sw.state(body,lo)[1]
    for _ in range(56):
        m=(lo+hi)/2; fm=sw.state(body,m)[1]
        if abs(fm)<1e-13: return m
        if flo*fm<=0: hi=m
        else: lo=m; flo=fm
        if (hi-lo)*SECONDS_PER_DAY<0.001: break
    return (lo+hi)/2

def refine_crossing(sw,body,target,lo,hi,anchor_lon,anchor_u):
    def val(jd):
        lon,speed=sw.state(body,jd)
        return anchor_u+delta(anchor_lon,lon)-target,speed
    a,b=lo,hi; fa,_=val(a); fb,_=val(b)
    if abs(fa)<1e-12:return a
    if abs(fb)<1e-12:return b
    if fa*fb>0:return (a+b)/2
    for _ in range(48):
        m=(a+b)/2; fm,_=val(m)
        if abs(fm)<1e-11:return m
        if fa*fm<=0:b=m
        else:a=m;fa=fm
        if (b-a)*SECONDS_PER_DAY<0.001:break
    return (a+b)/2

def emit(sw,body,res,span_start,span_end,lo,hi,ls,hs,out):
    lo_u=ls[0]; hi_u=lo_u+delta(ls[0],hs[0]); d=hi_u-lo_u
    if abs(d)<1e-14:return
    scale=round(1/res)
    if d>0:
        ks=range(math.floor(lo_u/res)+1, math.floor(hi_u/res)+1)
        direction=1
    else:
        ks=range(math.ceil(lo_u/res)-1, math.ceil(hi_u/res)-1, -1)
        direction=-1
    for k in ks:
        jd=refine_crossing(sw,body,k*res,lo,hi,ls[0],lo_u)
        if span_start-1e-9 <= jd < span_end-1e-9:
            tick=imod(k,360*scale)
            if not out or not (out[-1][1]==tick and abs(out[-1][0]-jd)*SECONDS_PER_DAY<0.25):
                out.append((jd,tick,direction))

def generate_body(sw,name,body,res,step,start,end):
    rows=[]; lo=start; ls=sw.state(body,lo)
    scaled=ls[0]/res; k=round(scaled)
    if abs(scaled-k)<1e-7:
        rows.append((start,imod(k,round(360/res)),1 if ls[1]>=0 else -1))
    while lo<end:
        hi=min(end,lo+step); hs=sw.state(body,hi)
        if ls[1]*hs[1]<0:
            sj=refine_station(sw,body,lo,hi); ss=sw.state(body,sj)
            if sj-lo>1e-10: emit(sw,body,res,start,end,lo,sj,ls,ss,rows)
            if hi-sj>1e-10: emit(sw,body,res,start,end,sj,hi,ss,hs,rows)
        else: emit(sw,body,res,start,end,lo,hi,ls,hs,rows)
        lo=hi; ls=hs
    rows.sort()
    baseline=rows if res==1.0 else [(jd,t//10,d) for jd,t,d in rows if t%10==0]
    return rows,baseline

def cell_before_first(rows):
    if not rows:return 0
    _,tick,d=rows[0]; return (tick-1)%360 if d>0 else tick

def cell_after(row):
    _,tick,d=row; return tick if d>0 else (tick-1)%360

def marker_cells(focal,marker):
    vals=[]; j=-1; before=cell_before_first(marker)
    for fr in focal:
        while j+1<len(marker) and marker[j+1][0] <= fr[0]+1e-12:j+=1
        vals.append(before if j<0 else cell_after(marker[j]))
    return vals

def repeated(ticks, arrays):
    seen={}; repeated_keys=0; repeated_rows=0
    for i,t in enumerate(ticks):
        key=(t,)+tuple(a[i] for a in arrays)
        seen[key]=seen.get(key,0)+1
    for n in seen.values():
        if n>1: repeated_keys+=1; repeated_rows+=n
    return repeated_keys,repeated_rows

def choose_markers(focal,rows,baselines):
    ticks=[r[1] for r in rows]
    arrays={n:marker_cells(rows,baselines[n]) for n,_,_,_ in BODIES if n!=focal}
    singles=[]
    for n in MARKER_PRIORITY:
        if n!=focal and n in arrays and repeated(ticks,[arrays[n]])[0]==0: singles.append(n)
    if focal!="Sun":
        s=arrays["Sun"]; sr,srows=repeated(ticks,[s])
        if sr==0:return ["Sun"],arrays,{"sunAloneRepeatedKeys":0,"sunAloneRepeatedRows":0,"singleMarkerWinners":singles,"sunFirst":True}
        candidates=[n for n in MARKER_PRIORITY if n not in (focal,"Sun")]
        for n in candidates:
            if repeated(ticks,[s,arrays[n]])[0]==0:return ["Sun",n],arrays,{"sunAloneRepeatedKeys":sr,"sunAloneRepeatedRows":srows,"singleMarkerWinners":singles,"sunFirst":True}
        for a,b in itertools.combinations(candidates,2):
            if repeated(ticks,[s,arrays[a],arrays[b]])[0]==0:return ["Sun",a,b],arrays,{"sunAloneRepeatedKeys":sr,"sunAloneRepeatedRows":srows,"singleMarkerWinners":singles,"sunFirst":True}
        raise RuntimeError(f"No Sun-first marker set <=3 resolved {focal}")
    if singles:return [singles[0]],arrays,{"sunAloneRepeatedKeys":None,"sunAloneRepeatedRows":None,"singleMarkerWinners":singles,"sunFirst":False}
    candidates=[n for n in MARKER_PRIORITY if n!=focal]
    for count in (2,3):
        for combo in itertools.combinations(candidates,count):
            if repeated(ticks,[arrays[n] for n in combo])[0]==0:return list(combo),arrays,{"sunAloneRepeatedKeys":None,"sunAloneRepeatedRows":None,"singleMarkerWinners":singles,"sunFirst":False}
    raise RuntimeError("No marker set <=3 resolved Sun")

def sha(path):
    h=hashlib.sha256()
    with open(path,'rb') as f:
        for chunk in iter(lambda:f.read(1024*1024),b''):h.update(chunk)
    return h.hexdigest()

def manufacture_span(sw,zid,start,end,start_utc,end_utc,root):
    root=Path(root)/zid.lower(); bodies_dir=root/'body-tables'; bodies_dir.mkdir(parents=True,exist_ok=True)
    all_rows={}; baselines={}
    for name,body,res,step in BODIES:
        rows,base=generate_body(sw,name,body,res,step,start,end); all_rows[name]=rows; baselines[name]=base
        print(f"{zid} scanned {name}: rows={len(rows)}")
    summaries=[]; files=[]; total=0
    for name,body,res,step in BODIES:
        rows=all_rows[name]; markers,arrays,audit=choose_markers(name,rows,baselines)
        audit["selectedMarkers"]=markers; audit["selectedRepeatedKeys"]=repeated([r[1] for r in rows],[arrays[m] for m in markers])[0]; audit["markerCount"]=len(markers)
        path=bodies_dir/f"{name}.csv.gz"; occurrence={}
        with gzip.open(path,'wt',newline='',compresslevel=9) as f:
            w=csv.writer(f); w.writerow(["focalCelestialTick","focalCelestialDegrees","celestialResolutionDegrees","occurrence","utOffsetSeconds","utJulianDay","sequenceDirection"]+[m+"Degree" for m in markers])
            for i,(jd,tick,d) in enumerate(rows):
                occurrence[tick]=occurrence.get(tick,0)+1
                w.writerow([tick,f"{tick*res:.1f}",f"{res:.1f}",occurrence[tick],round((jd-start)*SECONDS_PER_DAY),f"{jd:.12f}","increasing" if d>0 else "decreasing"]+[arrays[m][i] for m in markers])
        size=path.stat().st_size; files.append({"path":str(path.relative_to(root)),"bytes":size,"sha256":sha(path)}); total+=len(rows)
        summaries.append({"body":name,"selectedRecords":len(rows),"selectedResolutionDegrees":res,"selectedResolutionMarkerAudit":audit})
        print(f"{zid} AUDIT {name}: markers={markers} rows={len(rows)}")
    manifest={
      "zeitgeist":zid,"spanLaw":"half-open owner interval [first Pluto direct Aries ingress, next Zeitgeist first Pluto direct Aries ingress)",
      "celestialLaw":"body zodiacal position is primary celestial time; civic UT identifies occurrence only",
      "startJulianDayUT":start,"startUTC":start_utc,"endJulianDayUT":end,"endUTC":end_utc,
      "astronomicalSource":"Swiss Ephemeris DE441; geocentric tropical apparent ecliptic longitude; UT","swissVersion":sw.version,
      "bodyTableCount":11,"totalSelectedRecords":total,"bodyTables":summaries,"files":files,
      "resolutionLaw":"1 degree Sun through Mars; 0.1 degree Jupiter, Saturn, Uranus, Neptune, Pluto, True North Node",
      "nodeRepresentation":"True North Node; South Node derived at +180 degrees"
    }
    (root/'manifest.json').write_text(json.dumps(manifest,indent=2,sort_keys=True)+"\n")
    print(f"{zid} totalSelectedRecords={total}")
    return manifest

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--library',required=True); ap.add_argument('--ephe-dir',required=True); ap.add_argument('--output-root',required=True)
    a=ap.parse_args(); sw=Swiss(a.library,a.ephe_dir)
    if sw.version!="2.10.03":raise SystemExit(f"Unexpected Swiss version {sw.version}")
    out={}
    for zid,(s,e,su,eu) in SPANS.items():out[zid]=manufacture_span(sw,zid,s,e,su,eu,a.output_root)
    Path(a.output_root,'manifest.json').write_text(json.dumps({"artifactFamily":"Orbo Z21/Z23 celestial-first body occurrence tables","swissVersion":sw.version,"zeitgeists":out},indent=2,sort_keys=True)+"\n")
    print("PASS Z21/Z23 celestial-first body occurrence manufacture")

if __name__=='__main__':main()
