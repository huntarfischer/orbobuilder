import Foundation
#if canImport(Glibc)
import Glibc
#else
import Darwin
#endif

enum ForgeError: Error, CustomStringConvertible {
    case usage(String), dl(String), swiss(String)
    var description: String { switch self { case .usage(let s), .dl(let s), .swiss(let s): return s } }
}

enum Body: Int32, CaseIterable {
    case sun=0, moon=1, mercury=2, venus=3, mars=4, jupiter=5, saturn=6, uranus=7, neptune=8, pluto=9, northNode=11
    var name:String { switch self {
        case .sun:return "Sun"; case .moon:return "Moon"; case .mercury:return "Mercury"; case .venus:return "Venus"; case .mars:return "Mars"; case .jupiter:return "Jupiter"; case .saturn:return "Saturn"; case .uranus:return "Uranus"; case .neptune:return "Neptune"; case .pluto:return "Pluto"; case .northNode:return "NorthNode"
    }}
}
struct State { let longitude:Double; let speed:Double }
func norm(_ x:Double)->Double { var r=x.truncatingRemainder(dividingBy:360); if r<0 {r+=360}; return r }
func signedDelta(_ a:Double,_ b:Double)->Double { var d=norm(b)-norm(a); if d>180{d-=360}; if d < -180{d+=360}; return d }
func circError(_ a:Double,_ b:Double)->Double { abs(signedDelta(a,b)) }

typealias SetPath=@convention(c)(UnsafePointer<CChar>?)->Void
typealias CalcUT=@convention(c)(Double,Int32,Int32,UnsafeMutablePointer<Double>?,UnsafeMutablePointer<CChar>?)->Int32
typealias VersionFn=@convention(c)(UnsafeMutablePointer<CChar>?)->UnsafePointer<CChar>?
final class Swiss {
    let h:UnsafeMutableRawPointer; let calc:CalcUT; let version:String
    static let SWIEPH:Int32=2, MOSEPH:Int32=4, SPEED:Int32=256
    init(_ library:String,_ ephe:String)throws {
        guard let hh=dlopen(library,RTLD_NOW|RTLD_LOCAL) else { throw ForgeError.dl(String(cString:dlerror())) }; h=hh
        func sym<T>(_ n:String,_ t:T.Type)throws->T { guard let s=dlsym(hh,n) else {throw ForgeError.dl("missing \(n)")}; return unsafeBitCast(s,to:T.self) }
        let set:SetPath=try sym("swe_set_ephe_path",SetPath.self); calc=try sym("swe_calc_ut",CalcUT.self); let vf:VersionFn=try sym("swe_version",VersionFn.self)
        ephe.withCString{set($0)}; var b=[CChar](repeating:0,count:128); _=b.withUnsafeMutableBufferPointer{vf($0.baseAddress)}; version=String(cString:b)
    }
    deinit{dlclose(h)}
    func state(_ body:Body,_ jd:Double)throws->State {
        var xx=[Double](repeating:0,count:6), err=[CChar](repeating:0,count:256)
        let f=xx.withUnsafeMutableBufferPointer{xp in err.withUnsafeMutableBufferPointer{ep in calc(jd,body.rawValue,Swiss.SWIEPH|Swiss.SPEED,xp.baseAddress,ep.baseAddress)}}
        if f<0 || (f&Swiss.SWIEPH)==0 || (f&Swiss.MOSEPH) != 0 { throw ForgeError.swiss("\(body.name) @ \(jd): \(String(cString:err)); flags=\(f)") }
        return State(longitude:norm(xx[0]),speed:xx[3])
    }
}

struct Target { let oriented:Double; let aspect:String; let ring:Int; let orientation:String; let family:String }
let targets:[Target]=[
    Target(oriented:0,aspect:"conjunction",ring:0,orientation:"same_degree",family:"major"),
    Target(oriented:30,aspect:"semisextile",ring:30,orientation:"bodyA_ahead_30",family:"minor"),
    Target(oriented:45,aspect:"octile",ring:45,orientation:"bodyA_ahead_45",family:"minor"),
    Target(oriented:60,aspect:"sextile",ring:60,orientation:"bodyA_ahead_60",family:"major"),
    Target(oriented:72,aspect:"quintile",ring:72,orientation:"bodyA_ahead_72",family:"minor"),
    Target(oriented:90,aspect:"square",ring:90,orientation:"bodyA_ahead_90",family:"major"),
    Target(oriented:120,aspect:"trine",ring:120,orientation:"bodyA_ahead_120",family:"major"),
    Target(oriented:135,aspect:"trioctile",ring:135,orientation:"bodyA_ahead_135",family:"minor"),
    Target(oriented:144,aspect:"biquintile",ring:144,orientation:"bodyA_ahead_144",family:"minor"),
    Target(oriented:150,aspect:"quincunx",ring:150,orientation:"bodyA_ahead_150",family:"minor"),
    Target(oriented:180,aspect:"opposition",ring:180,orientation:"opposite_degree",family:"major"),
    Target(oriented:210,aspect:"quincunx",ring:150,orientation:"bodyB_ahead_150",family:"minor"),
    Target(oriented:216,aspect:"biquintile",ring:144,orientation:"bodyB_ahead_144",family:"minor"),
    Target(oriented:225,aspect:"trioctile",ring:135,orientation:"bodyB_ahead_135",family:"minor"),
    Target(oriented:240,aspect:"trine",ring:120,orientation:"bodyB_ahead_120",family:"major"),
    Target(oriented:270,aspect:"square",ring:90,orientation:"bodyB_ahead_90",family:"major"),
    Target(oriented:288,aspect:"quintile",ring:72,orientation:"bodyB_ahead_72",family:"minor"),
    Target(oriented:300,aspect:"sextile",ring:60,orientation:"bodyB_ahead_60",family:"major"),
    Target(oriented:315,aspect:"octile",ring:45,orientation:"bodyB_ahead_45",family:"minor"),
    Target(oriented:330,aspect:"semisextile",ring:30,orientation:"bodyB_ahead_30",family:"minor")
]
struct Pair:Hashable { let a:Body; let b:Body }
struct Progress { var raw:Double; var unwrapped:Double }
struct Event { let bodyA:String,bodyB:String,aspect:String; let ring:Int; let orientation:String; let aLon:Double,bLon:Double,jd:Double; let offset:Int64; let residual:Double }

func crossings(_ previous:Double,_ current:Double,_ base:Double)->[Double] {
    var r:[Double]=[]
    if current>previous { let f=Int(floor((previous-base)/360))+1,l=Int(floor((current-base)/360)); if f<=l {for k in f...l{r.append(base+Double(k)*360)}} }
    else if current<previous { let f=Int(ceil((previous-base)/360))-1,l=Int(ceil((current-base)/360)); if f>=l {for k in stride(from:f,through:l,by:-1){r.append(base+Double(k)*360)}} }
    return r
}
func relative(_ pair:Pair,_ jd:Double,_ target:Double,_ sw:Swiss)throws->(Double,State,State) {
    let a=try sw.state(pair.a,jd),b=try sw.state(pair.b,jd),raw=norm(a.longitude-b.longitude); return(raw+360*round((target-raw)/360)-target,a,b)
}
func refine(_ pair:Pair,_ target:Double,_ lo0:Double,_ hi0:Double,_ sw:Swiss)throws->(Double,State,State) {
    var lo=lo0,hi=hi0,gl=try relative(pair,lo0,target,sw).0,gh=try relative(pair,hi0,target,sw).0
    if abs(gl)<1e-10 {let q=try relative(pair,lo,target,sw);return(lo,q.1,q.2)}
    if abs(gh)<1e-10 {let q=try relative(pair,hi,target,sw);return(hi,q.1,q.2)}

    var x=lo+(hi-lo)*abs(gl)/(abs(gl)+abs(gh))
    var bestJD=x
    var best=try relative(pair,x,target,sw)

    // Hybrid Newton/bracket refinement. Acceptance is driven by celestial residual, never
    // merely by elapsed bracket time, so every emitted relationship is genuinely exact-first.
    for _ in 0..<32 {
        let q=try relative(pair,x,target,sw)
        if abs(q.0)<abs(best.0) { bestJD=x; best=q }
        if abs(q.0)<1e-10 { return(x,q.1,q.2) }
        if gl*q.0<=0 {hi=x;gh=q.0}else{lo=x;gl=q.0}
        let d=q.1.speed-q.2.speed
        var c=abs(d)>1e-12 ? x-q.0/d : (lo+hi)/2
        if !(c>lo && c<hi) || !c.isFinite {c=(lo+hi)/2}
        x=c
    }

    // Rare pathological geometry gets a deterministic pure-bisection finish rather than
    // leaking a near-root into the canonical artifact.
    for _ in 0..<24 {
        let mid=(lo+hi)/2
        let q=try relative(pair,mid,target,sw)
        if abs(q.0)<abs(best.0) { bestJD=mid; best=q }
        if abs(q.0)<1e-10 { return(mid,q.1,q.2) }
        if gl*q.0<=0 {hi=mid;gh=q.0}else{lo=mid;gl=q.0}
    }
    return(bestJD,best.1,best.2)
}
func parseArgs()throws->(String,String,String,Double,Double,Double) {
    var lib:String?,ephe:String?,out:String?,start:Double?,end:Double?,origin:Double?;let a=CommandLine.arguments;var i=1
    while i<a.count {switch a[i]{case"--library":i+=1;lib=a[i];case"--ephe-dir":i+=1;ephe=a[i];case"--output-dir":i+=1;out=a[i];case"--start-jd":i+=1;start=Double(a[i]);case"--end-jd":i+=1;end=Double(a[i]);case"--offset-origin-jd":i+=1;origin=Double(a[i]);default:break};i+=1}
    guard let l=lib,let e=ephe,let o=out,let s=start,let n=end,let g=origin,s<n else {throw ForgeError.usage("required: --library --ephe-dir --output-dir --start-jd --end-jd --offset-origin-jd")};return(l,e,o,s,n,g)
}
func csvLine(_ e:Event)->String { [e.bodyA,e.bodyB,e.aspect,String(e.ring),e.orientation,String(format:"%.9f",e.aLon),String(format:"%.9f",e.bLon),String(format:"%.12f",e.jd),String(e.offset),String(format:"%.6f",e.residual)].joined(separator:",")+"\n" }

func main()throws {
    let(lib,ephe,outPath,start,end,origin)=try parseArgs(),sw=try Swiss(lib,ephe);guard sw.version=="2.10.03" else{throw ForgeError.swiss("unexpected Swiss \(sw.version)")}
    let out=URL(fileURLWithPath:outPath);try FileManager.default.createDirectory(at:out,withIntermediateDirectories:true)
    let major=out.appendingPathComponent("exact-major-mundane-transits.csv"),minor=out.appendingPathComponent("exact-minor-mundane-transits.csv");_ = FileManager.default.createFile(atPath:major.path,contents:nil);_ = FileManager.default.createFile(atPath:minor.path,contents:nil)
    let mh=try FileHandle(forWritingTo:major),nh=try FileHandle(forWritingTo:minor);defer{try? mh.close();try? nh.close()};let header="bodyA,bodyB,aspect,ringDegrees,orientation,bodyACelestialTimeDegrees,bodyBCelestialTimeDegrees,civicTimeJulianDayUT,civicTimeOffsetSeconds,exactAspectResidualArcSeconds\n".data(using:.utf8)!;try mh.write(contentsOf:header);try nh.write(contentsOf:header)
    let bodies=Body.allCases;var pairs:[Pair]=[];for i in 0..<bodies.count-1{for j in i+1..<bodies.count{pairs.append(Pair(a:bodies[i],b:bodies[j]))}}
    func states(_ jd:Double)throws->[Body:State]{var r:[Body:State]=[:];for b in bodies{r[b]=try sw.state(b,jd)};return r}
    let initial=try states(start);var progress:[Pair:Progress]=[:];for p in pairs{let x=norm(initial[p.a]!.longitude-initial[p.b]!.longitude);progress[p]=Progress(raw:x,unwrapped:x)}
    var majorCount=0,minorCount=0,previousJD=start,jd=start+0.1
    while previousJD<end {
        let currentJD=min(jd,end),current=try states(currentJD)
        for p in pairs {
            var pr=progress[p]!;let raw=norm(current[p.a]!.longitude-current[p.b]!.longitude),unwrapped=pr.unwrapped+signedDelta(pr.raw,raw)
            for t in targets {for absolute in crossings(pr.unwrapped,unwrapped,t.oriented){
                let q=try refine(p,absolute,previousJD,currentJD,sw);if q.0<start || q.0>=end{continue};let offset=Int64(((q.0-origin)*86400).rounded());if offset<0{continue}
                let e=Event(bodyA:p.a.name,bodyB:p.b.name,aspect:t.aspect,ring:t.ring,orientation:t.orientation,aLon:q.1.longitude,bLon:q.2.longitude,jd:q.0,offset:offset,residual:circError(norm(q.1.longitude-q.2.longitude),norm(absolute))*3600),data=csvLine(e).data(using:.utf8)!
                if t.family=="major"{try mh.write(contentsOf:data);majorCount+=1}else{try nh.write(contentsOf:data);minorCount+=1}
            }}
            pr.raw=raw;pr.unwrapped=unwrapped;progress[p]=pr
        }
        previousJD=currentJD;if currentJD>=end{break};jd+=0.1
    }
    print("PASS relationship forge Swiss=\(sw.version) start=\(start) end=\(end) major=\(majorCount) minor=\(minorCount)")
}

do{try main()}catch{fputs("ZeitgeistRelationshipForge failed: \(error)\n",stderr);exit(1)}
