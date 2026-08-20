#!/usr/bin/env python3
"""Size/fidelity bench for uniform Z21-Z23 Mundane Timespine cadence candidates."""
from __future__ import annotations
import argparse,csv,json,math,random,statistics,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
import generate_swiss_samples as gs

SCALE=3_600_000; CIRCLE=360*SCALE
BODIES=tuple(gs.BODY_IDS)
SHELLS=("Z21.08","Z22.08","Z23.08")
FULL_START="Z21.01"; FULL_END="Z23.12"
SPLIT1=2_433_282.5; SPLIT2=2_469_807.5
TIERS={
 "lower":{"Sun":2.0,"Moon":.25,"Mercury":1/12,"Venus":.25,"Mars":.5,"Jupiter":.5,"Saturn":1.0,"Uranus":.25,"Neptune":.5,"Pluto":.5,"True North Node":.125},
 "higher":{"Sun":1.0,"Moon":.125,"Mercury":1/48,"Venus":.0625,"Mars":.125,"Jupiter":.125,"Saturn":.125,"Uranus":.0625,"Neptune":.125,"Pluto":.125,"True North Node":1/48},
}
GATES={"lower":.05,"higher":.01}; P999_GATE=.01; SPEED_GATE=.005; FINE_GATE=.995; MOTION_GATE=.99999

def norm(x):
 x=math.fmod(x,360.0); return x+360 if x<0 else (0.0 if x==0 else x)
def wrap(x):
 x=math.fmod(x+180,360.0); x=x+360 if x<0 else x; return x-180
def quant(x): return int(math.floor(norm(x)*SCALE+.5))%CIRCLE
def fine(x): return int(math.floor(norm(x)*3600))%1_296_000
def motion(x): return "retrograde" if x<0 else "direct"
def count(a,b,s): return max(4,math.ceil((b-a)/s)+1)
def delta(a,b):
 d=b-a; h=CIRCLE//2
 if d>h:d-=CIRCLE
 elif d<-h:d+=CIRCLE
 return d
def varlen(v):
 z=v*2 if v>=0 else -v*2-1; n=1
 while z>=128:z>>=7;n+=1
 return n
def pack_bytes(p):
 n=4; prev=p[0]; pd=delta(prev,p[1]); n+=varlen(pd); prev=p[1]
 for cur in p[2:]:
  d=delta(prev,cur); n+=varlen(d-pd); pd=d; prev=cur
 return n
def pct(v,q):
 if not v:return 0.0
 o=sorted(v); return o[min(len(o)-1,max(0,math.ceil(q*len(o))-1))]

def interp(pos,start,step,jd):
 x=(jd-start)/step; k=math.floor(x); first=min(max(0,k-1),len(pos)-4); ids=[first+i for i in range(4)]
 raw=[pos[i]/SCALE for i in ids]; u=[raw[0]]
 for v in raw[1:]:u.append(u[-1]+wrap(v-norm(u[-1])))
 val=der=0.0
 for i,xi0 in enumerate(ids):
  xi=float(xi0); basis=1.0
  for j,xj0 in enumerate(ids):
   if j!=i:basis*=(x-float(xj0))/(xi-float(xj0))
  db=0.0
  for m,xm0 in enumerate(ids):
   if m==i:continue
   term=1.0/(xi-float(xm0))
   for j,xj0 in enumerate(ids):
    if j!=i and j!=m:term*=(x-float(xj0))/(xi-float(xj0))
   db+=term
  val+=u[i]*basis; der+=u[i]*db
 return norm(val),der/step

def expected_motion(c,jd):
 st=c["stations"]; lo=0; hi=len(st)
 while lo<hi:
  m=(lo+hi)//2
  if st[m]["julianDay"]<=jd:lo=m+1
  else:hi=m
 return c["initialMotion"] if lo==0 else st[lo-1]["motionAfter"]

def probes(start,end,c,seed,n):
 r=random.Random(seed); out=[start+r.random()*(end-start) for _ in range(n)]
 for s in c["stations"]:
  for off in (-5/1440,-1/1440,1/1440,5/1440):
   x=s["julianDay"]+off
   if start<=x<end:out.append(x)
 return out

def bench_body(sw,shell,start,end,body,tier,step,c,nprobe):
 bid=gs.BODY_IDS[body]; nk=count(start,end,step); pos=[]
 for i in range(nk):pos.append(quant(sw.state(start+i*step,bid)[0]))
 pb=pack_bytes(pos); raw=nk*4; ae=[]; se=[]; fm=mm=0
 seed=0x4F52424F+BODIES.index(body)*10000+SHELLS.index(shell)*100+(tier=="higher")
 ps=probes(start,end,c,seed,nprobe)
 for jd in ps:
  rl,rs=sw.state(jd,bid); sl,ds=interp(pos,start,step,jd); em=expected_motion(c,jd); ss=-abs(ds) if em=="retrograde" else abs(ds)
  ae.append(abs(wrap(sl-rl))*3600); se.append(abs(ss-rs)); fm+=fine(sl)==fine(rl); mm+=motion(ss)==motion(rs)
 mx=max(ae,default=0); p999=pct(ae,.999); ms=max(se,default=0); fa=fm/len(ps); ma=mm/len(ps)
 gate=mx<=GATES[tier] and p999<=P999_GATE and ms<=SPEED_GATE and fa>=FINE_GATE and ma>=MOTION_GATE
 return {"shellSign":shell,"tier":tier,"body":body,"sampleDays":step,"spanDays":end-start,"knotCount":nk,"rawPositionBytes":raw,"packedPositionBytes":pb,"packedBytesPerKnot":pb/nk,"positionPackingRatio":pb/raw,"stationCount":len(c["stations"]),"probeCount":len(ps),"maxAngularArcseconds":mx,"p999AngularArcseconds":p999,"p99AngularArcseconds":pct(ae,.99),"medianAngularArcseconds":statistics.median(ae),"maxSpeedErrorDegreesPerDay":ms,"fineStateAgreement":fa,"motionAgreement":ma,"referenceAuditGatePass":gate}

def rows(path):
 with path.open(newline="") as f:return {r["shell_sign_id"]:r for r in csv.DictReader(f)}
def region_counts(a,b,s):
 bounds=(a,SPLIT1,SPLIT2,b) if a<SPLIT1<SPLIT2<b else (a,a+(b-a)/3,a+2*(b-a)/3,b)
 return [count(bounds[i],bounds[i+1],s) for i in range(3)]

def project(results,a,b):
 out={}; span=b-a
 for tier,steps in TIERS.items():
  bs=[]
  for body in BODIES:
   q=[r for r in results if r["tier"]==tier and r["body"]==body]; ratios=[r["positionPackingRatio"] for r in q]
   ratio=sum(r["packedPositionBytes"] for r in q)/sum(r["rawPositionBytes"] for r in q); rc=region_counts(a,b,steps[body]); knots=sum(rc); raw=knots*4
   st=round(sum(r["stationCount"] for r in q)*span/sum(r["spanDays"] for r in q)); pp=round(raw*ratio); lo=round(raw*min(ratios)); hi=round(raw*max(ratios)); fixed=21+3*28+st*9
   bs.append({"body":body,"sampleDays":steps[body],"regionKnotCounts":rc,"fullKnotCount":knots,"rawPositionBytes":raw,"benchWeightedPackingRatio":ratio,"benchPackingRatioMin":min(ratios),"benchPackingRatioMax":max(ratios),"projectedStationCount":st,"projectedPackedPositionBytes":pp,"projectedBodyBytes":fixed+pp,"projectedBodyBytesMin":fixed+lo,"projectedBodyBytesMax":fixed+hi,"benchReferenceGatePassAll":all(r["referenceAuditGatePass"] for r in q),"benchMaxAngularArcseconds":max(r["maxAngularArcseconds"] for r in q),"benchMaxP999AngularArcseconds":max(r["p999AngularArcseconds"] for r in q),"benchMinFineStateAgreement":min(r["fineStateAgreement"] for r in q),"benchMinMotionAgreement":min(r["motionAgreement"] for r in q),"benchMaxSpeedErrorDegreesPerDay":max(r["maxSpeedErrorDegreesPerDay"] for r in q)})
  total=sum(x["projectedBodyBytes"] for x in bs); mn=sum(x["projectedBodyBytesMin"] for x in bs); mx=sum(x["projectedBodyBytesMax"] for x in bs)
  out[tier]={"bodies":bs,"rawPositionBytes":sum(x["rawPositionBytes"] for x in bs),"projectedBodyArtifactBytes":total,"projectedBodyArtifactBytesMin":mn,"projectedBodyArtifactBytesMax":mx,"projectedBodyArtifactMiB":total/1048576,"projectedBodyArtifactMiBMin":mn/1048576,"projectedBodyArtifactMiBMax":mx/1048576,"allBodiesPassReferenceAuditGatesAcrossBench":all(x["benchReferenceGatePassAll"] for x in bs)}
 return out

def markdown(d):
 L=["# Mundane Timespine Z21-Z23 sizing bench","","Sizing/fidelity benchmark only. This is not a canonical manufacture or final qualification.","",f"Full range: `{d['fullRange']['startUTC']}` through `{d['fullRange']['endUTC']}` ({d['fullRange']['spanYears']:.3f} Julian years).","","## Full-range projection","","| Tier | Raw positions | Projected body artifacts | Bench-era range | Reference gates |","| --- | ---: | ---: | ---: | --- |"]
 for t in ("lower","higher"):
  p=d["projection"][t]; L.append(f"| {t} | {p['rawPositionBytes']/1048576:.2f} MiB | {p['projectedBodyArtifactMiB']:.2f} MiB | {p['projectedBodyArtifactMiBMin']:.2f}-{p['projectedBodyArtifactMiBMax']:.2f} MiB | {'PASS' if p['allBodiesPassReferenceAuditGatesAcrossBench'] else 'FAIL'} |")
 for t in ("lower","higher"):
  L += ["",f"## {t} per body","","| Body | Cadence | Raw MiB | Projected MiB | Packing | Max arcsec | P99.9 arcsec | Fine state | Gate |","| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |"]
  for x in d["projection"][t]["bodies"]:L.append(f"| {x['body']} | {x['sampleDays']:.8g} d | {x['rawPositionBytes']/1048576:.2f} | {x['projectedBodyBytes']/1048576:.2f} | {x['benchWeightedPackingRatio']:.3f} | {x['benchMaxAngularArcseconds']:.6f} | {x['benchMaxP999AngularArcseconds']:.6f} | {x['benchMinFineStateAgreement']:.6f} | {'PASS' if x['benchReferenceGatePassAll'] else 'FAIL'} |")
 L += ["","## Bench slices",""]+[f"- `{x['shellSign']}`: {x['startUTC']} through {x['endUTC']} ({x['spanDays']:.3f} days)" for x in d["benchSlices"]]
 return "\n".join(L)+"\n"

def main():
 p=argparse.ArgumentParser(); p.add_argument("--library",required=True); p.add_argument("--ephe-dir",required=True); p.add_argument("--shell-csv",required=True); p.add_argument("--report",required=True); p.add_argument("--markdown",required=True); p.add_argument("--random-probes",type=int,default=2000); a=p.parse_args()
 rr=rows(Path(a.shell_csv)); fs=rr[FULL_START]; fe=rr[FULL_END]; start=float(fs["first_direct_ingress_jd_ut"]); end=float(fe["next_sign_first_direct_ingress_jd_ut"]); files=gs.verify_files(Path(a.ephe_dir)); sw=gs.SwissC(Path(a.library),Path(a.ephe_dir)); res=[]; slices=[]
 try:
  for shell in SHELLS:
   r=rr[shell]; x=float(r["first_direct_ingress_jd_ut"]); y=float(r["next_sign_first_direct_ingress_jd_ut"]); slices.append({"shellSign":shell,"startJulianDay":x,"endJulianDay":y,"startUTC":r["first_direct_ingress_utc"],"endUTC":r["next_sign_first_direct_ingress_utc"],"spanDays":y-x}); c={}
   for body in BODIES:print(f"[{shell}] stations {body}",flush=True); c[body]=gs.station_chronology(sw,body,gs.BODY_IDS[body],x,y)
   for tier,steps in TIERS.items():
    for body in BODIES:print(f"[{shell}] {tier} {body} @ {steps[body]:.9g} d",flush=True); res.append(bench_body(sw,shell,x,y,body,tier,steps[body],c[body],a.random_probes))
 finally:sw.close()
 d={"status":"timespine-sizing-bench","codecMeasured":4,"positionUnitsPerDegree":SCALE,"source":"official Swiss Ephemeris C / DE441","swissLibraryVersion":gs.EXPECTED_SWE_VERSION,"ephemerisFiles":files,"benchShellSigns":list(SHELLS),"benchSlices":slices,"randomProbesPerBodyTierSlice":a.random_probes,"fullRange":{"startShellSign":FULL_START,"endShellSign":FULL_END,"startJulianDay":start,"endJulianDay":end,"startUTC":fs["first_direct_ingress_utc"],"endUTC":fe["next_sign_first_direct_ingress_utc"],"spanDays":end-start,"spanYears":(end-start)/365.25},"cadenceTiers":TIERS,"results":res,"projection":project(res,start,end),"notes":["Projection measures codec-4 quantization and second-delta varint packing across Z21.08, Z22.08, and Z23.08.","Full-range knot counts retain three codec regions but use one uniform cadence per body, so 1950-2050 receives no resolution privilege.","Station bytes are projected from station density in the three bench slices and are tiny relative to position payload.","Reference audit gates are comparison labels only; the manufactured full range still requires final qualification.","Manifest bytes are excluded from projected body-artifact totals."]}
 Path(a.report).parent.mkdir(parents=True,exist_ok=True); Path(a.report).write_text(json.dumps(d,indent=2,sort_keys=True)+"\n"); Path(a.markdown).write_text(markdown(d)); print(markdown(d)); return 0
if __name__=="__main__":
 try:raise SystemExit(main())
 except Exception as e:print(f"TIMESPINE SIZING BENCH FAILURE: {e}",file=sys.stderr);raise
