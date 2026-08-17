import argparse,ctypes,csv,itertools,json,math,os
from datetime import datetime,timezone,timedelta
P=[('Sun',0),('Moon',1),('Mercury',2),('Venus',3),('Mars',4),('Jupiter',5),('Saturn',6),('Uranus',7),('Neptune',8),('Pluto',9),('NorthNode',11)]
PD=dict(P); NAMES=[x for x,_ in P]

def norm(x): return x%360.0
def dlt(a,b): return (b-a+180)%360-180
def jd(y,m,d):
 if m<=2:y-=1;m+=12
 a=y//100;b=2-a+a//4
 return int(365.25*(y+4716))+int(30.6001*(m+1))+d+b-1524.5
def iso(j): return (datetime(1970,1,1,tzinfo=timezone.utc)+timedelta(seconds=(j-2440587.5)*86400)).isoformat().replace('+00:00','Z')
class S:
 def __init__(self,lib,ep):
  self.l=ctypes.CDLL(lib);self.l.swe_set_ephe_path.argtypes=[ctypes.c_char_p];self.l.swe_set_ephe_path(ep.encode());self.l.swe_calc_ut.argtypes=[ctypes.c_double,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_double),ctypes.c_char_p];self.l.swe_calc_ut.restype=ctypes.c_int32
 def st(self,b,t):
  x=(ctypes.c_double*6)();e=ctypes.create_string_buffer(256);r=self.l.swe_calc_ut(t,b,258,x,e)
  if r<0 or not(r&2) or r&4: raise RuntimeError(e.value.decode())
  return norm(x[0]),x[3]
def refine(fun,a,b,n=44):
 fa=fun(a);fb=fun(b)
 for _ in range(n):
  m=(a+b)/2;fm=fun(m)
  if fa*fm<=0:b=m;fb=fm
  else:a=m;fa=fm
 return (a+b)/2
def zcross(sw,b,a,z,step):
 out=[];t=a;l,_=sw.st(b,t);u=l
 while t<z:
  q=min(t+step,z);nl,_=sw.st(b,q);du=dlt(l,nl);nu=u+du
  if du>0:
   ks=range(math.floor(u/360)+1,math.floor(nu/360)+1)
  elif du<0:
   ks=range(math.ceil(u/360)-1,math.ceil(nu/360)-1,-1)
  else:ks=[]
  for _ in ks:
   r=refine(lambda x:dlt(0,sw.st(b,x)[0]),t,q);sp=sw.st(b,r)[1];out.append((r,1 if sp>=0 else -1))
  t,l,u=q,nl,nu
 return out
def cycle(sw,name,b,a,z,step,prim):
 c=[x for x in zcross(sw,b,a,z,step) if x[1]==prim];g=[]
 for x in c:
  if not g or x[0]-g[-1][0]>3*365.2425:g.append(x)
 s=max(x for x in g if x[0]<=jd(1985,1,1));e=min(x for x in g if x[0]>=jd(1986,12,31));return s[0],e[0]
def crosses(sw,b,a,z,step):
 out=[(0,a,1 if sw.st(b,a+.001)[1]>=0 else -1)];t=a;l,_=sw.st(b,t);u=l
 while t<z:
  q=min(t+step,z);nl,_=sw.st(b,q);du=dlt(l,nl);nu=u+du
  if du>0: ks=range(math.floor(u*10)+1,math.floor(nu*10)+1)
  elif du<0:ks=range(math.ceil(u*10)-1,math.ceil(nu*10)-1,-1)
  else:ks=[]
  for k in ks:
   tick=k%3600;target=tick/10;r=refine(lambda x:dlt(target,sw.st(b,x)[0]),t,q);out.append((tick,r,1 if du>0 else -1))
  t,l,u=q,nl,nu
 out.sort(key=lambda x:x[1]);ded=[]
 for x in out:
  if ded and x[0]==ded[-1][0] and abs(x[1]-ded[-1][1])<1e-5:continue
  ded.append(x)
 return ded
def stations(sw,b,a,z,step):
 o=[];t=a;sp=sw.st(b,t)[1]
 while t<z:
  q=min(t+step,z);nsp=sw.st(b,q)[1]
  if sp*nsp<0:
   r=refine(lambda x:sw.st(b,x)[1],t,q,50);lo=sw.st(b,r)[0];o.append((r,lo,'increasing' if sp>0 else 'decreasing','increasing' if nsp>0 else 'decreasing'))
  t,sp=q,nsp
 return o
def stat(e):
 if not e:return {'n':0,'median_s':0,'p95_s':0,'max_s':0}
 e=sorted(e);q=lambda p:e[min(len(e)-1,int(round((len(e)-1)*p)))];return {'n':len(e),'median_s':q(.5),'p95_s':q(.95),'max_s':e[-1]}
def interp(hi,stn):
 wh=[x for x in hi if x[0]%10==0];lin=[];quad=[];sj=[x[0] for x in stn]
 def clear(a,b): return not any(a<q<b for q in sj)
 for i in range(len(wh)-1):
  a,b=wh[i],wh[i+1];ex=(a[0]+(10 if a[2]>0 else -10))%3600
  if a[2]!=b[2] or b[0]!=ex or not clear(a[1],b[1]):continue
  for h in hi:
   if a[1]<h[1]<b[1] and h[2]==a[2]:
    f=((h[0]-a[0])%3600 if a[2]>0 else (a[0]-h[0])%3600)/10;lin.append(abs((a[1]+f*(b[1]-a[1])-h[1])*86400))
 for i in range(len(wh)-2):
  a,b,c=wh[i:i+3]
  if not(a[2]==b[2]==c[2]) or not clear(a[1],c[1]):continue
  if b[0]!=(a[0]+(10 if a[2]>0 else -10))%3600 or c[0]!=(b[0]+(10 if b[2]>0 else -10))%3600:continue
  for h in hi:
   if b[1]<h[1]<c[1] and h[2]==b[2]:
    f=((h[0]-b[0])%3600 if b[2]>0 else (b[0]-h[0])%3600)/10;x=1+f;y=a[1]*(x-1)*(x-2)/2+b[1]*(-x*(x-2))+c[1]*x*(x-1)/2;quad.append(abs((y-h[1])*86400))
 return stat(lin),stat(quad)
def markers(rows,focal):
 cand=[n for n in NAMES if n!=focal]
 def met(ms):
  d={}
  for r in rows:
   k=(r['deg'],)+tuple(r[m] for m in ms);d[k]=d.get(k,0)+1
  return sum(v-1 for v in d.values() if v>1),sum(v==1 for v in d.values())
 rates=[]
 for m in cand:
  c,u=met([m]);rates.append({'marker':m,'unique_fraction':u/len(rows),'collision_excess':c})
 sol=[];k=0
 for k in range(1,len(cand)+1):
  sol=[list(x) for x in itertools.combinations(cand,k) if met(x)[0]==0]
  if sol:break
 return {'minimal_count':k,'selected':sol[0] if sol else [],'solutions':sol,'single_rates':sorted(rates,key=lambda x:(-x['unique_fraction'],x['marker']))}
def main():
 A=argparse.ArgumentParser();A.add_argument('--library');A.add_argument('--ephe-dir');A.add_argument('--output-dir');a=A.parse_args();os.makedirs(a.output_dir,exist_ok=True);sw=S(a.library,a.ephe_dir)
 specs=[('NorthNode',11,jd(1940,1,1),jd(2005,1,1),.25,.125,-1),('Uranus',7,jd(1880,1,1),jd(2050,1,1),1,1,1),('Neptune',8,jd(1800,1,1),jd(2100,1,1),1,1,1),('Pluto',9,jd(1800,1,1),jd(2100,1,1),1,1,1)];SUM=[]
 for name,b,sa,sz,step,sstep,prim in specs:
  start,end=cycle(sw,name,b,sa,sz,step,prim);hi=crosses(sw,b,start,end,step);wh=[(t//10,j,d) for t,j,d in hi if t%10==0];stn=stations(sw,b,start,end,sstep);bounds=[start]+[x[0] for x in stn]+[end];retro=[]
  for x,y in zip(bounds,bounds[1:]):
   if sw.st(b,(x+y)/2)[1]<0:retro.append({'start_celestial':sw.st(b,x)[0],'end_celestial':sw.st(b,y)[0],'start_jd':x,'end_jd':y,'whole_degree_crossings':sum(d<0 and x-1e-7<=j<=y+1e-7 for _,j,d in wh)})
  rows=[]
  for deg,t,d in wh:
   r={'deg':deg,'jd':t,'sequence':'increasing' if d>0 else 'decreasing'}
   for n,i in P:r[n]=int(sw.st(i,t)[0])
   rows.append(r)
  ma=markers(rows,name);cnt={}
  for d,_,_ in wh:cnt[d]=cnt.get(d,0)+1
  li,qu=interp(hi,stn);dur=end-start;bits=math.ceil(math.log2(dur*86400+1));m=ma['minimal_count'];store={'offset_bits':bits,'offset_bytes':math.ceil(bits/8),'simple_total_bytes':len(rows)*(math.ceil(bits/8)+2+2*m),'packed_total_bytes':math.ceil(len(rows)*(bits+9*m)/8)}
  sm={'body':name,'cycle_start_jd':start,'cycle_end_jd':end,'cycle_start_utc':iso(start),'cycle_end_utc':iso(end),'duration_days':dur,'duration_years':dur/365.2425,'whole_degree_crossings':len(wh),'tenth_degree_crossings':len(hi),'repeated_whole_degrees':sum(v>1 for v in cnt.values()),'max_occurrences_one_degree':max(cnt.values()),'stations':len(stn),'retrograde_passages':len(retro),'retrograde_whole_degree_crossings':sum(x['whole_degree_crossings'] for x in retro),'linear_interpolation':li,'quadratic_interpolation':qu,'markers':ma,'storage':store};SUM.append(sm)
  od=os.path.join(a.output_dir,name);os.makedirs(od,exist_ok=True);json.dump(sm,open(os.path.join(od,'summary.json'),'w'),indent=2);json.dump([{'celestial_time':x[1],'jd':x[0],'utc':iso(x[0]),'before':x[2],'after':x[3]} for x in stn],open(os.path.join(od,'stations-celestial-time.json'),'w'),indent=2);json.dump(retro,open(os.path.join(od,'retrograde-celestial-time.json'),'w'),indent=2)
  fields=['deg','jd','sequence']+ma['selected'];w=csv.DictWriter(open(os.path.join(od,'body-table.csv'),'w',newline=''),fieldnames=fields);w.writeheader();w.writerows({k:r[k] for k in fields} for r in rows);print(name,json.dumps(sm))
 json.dump({'status':'comparative body-cycle learning specimen','source':'Swiss Ephemeris DE441 geocentric tropical apparent longitude UT','node':'True North Node; South Node derived +180 degrees','bodies':SUM},open(os.path.join(a.output_dir,'summary.json'),'w'),indent=2)
if __name__=='__main__':main()
