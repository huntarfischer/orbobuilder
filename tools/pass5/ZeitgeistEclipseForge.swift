import Foundation
#if canImport(Glibc)
import Glibc
#else
import Darwin
#endif

enum ForgeError: Error, CustomStringConvertible {
    case usage(String), dl(String), swiss(String), root(String)
    var description: String { switch self { case .usage(let s), .dl(let s), .swiss(let s), .root(let s): return s } }
}

func norm(_ x: Double) -> Double { var r=x.truncatingRemainder(dividingBy:360); if r<0 { r += 360 }; return r }
func signed180(_ x: Double) -> Double { var r=x.truncatingRemainder(dividingBy:360); if r>180 {r-=360}; if r <= -180 {r+=360}; return r }

struct State { let longitude: Double; let speed: Double }

typealias SetPath = @convention(c) (UnsafePointer<CChar>?) -> Void
typealias CalcUT = @convention(c) (Double, Int32, Int32, UnsafeMutablePointer<Double>?, UnsafeMutablePointer<CChar>?) -> Int32
typealias VersionFn = @convention(c) (UnsafeMutablePointer<CChar>?) -> UnsafePointer<CChar>?
typealias SolarWhen = @convention(c) (Double, Int32, Int32, UnsafeMutablePointer<Double>?, Int32, UnsafeMutablePointer<CChar>?) -> Int32
typealias LunarWhen = @convention(c) (Double, Int32, Int32, UnsafeMutablePointer<Double>?, Int32, UnsafeMutablePointer<CChar>?) -> Int32
typealias SolarWhere = @convention(c) (Double, Int32, UnsafeMutablePointer<Double>?, UnsafeMutablePointer<Double>?, UnsafeMutablePointer<CChar>?) -> Int32
typealias LunarHow = @convention(c) (Double, Int32, UnsafeMutablePointer<Double>?, UnsafeMutablePointer<Double>?, UnsafeMutablePointer<CChar>?) -> Int32

final class Swiss {
    let h: UnsafeMutableRawPointer
    let calc: CalcUT
    let solarWhen: SolarWhen
    let lunarWhen: LunarWhen
    let solarWhere: SolarWhere
    let lunarHow: LunarHow
    let version: String
    static let SWIEPH:Int32=2, MOSEPH:Int32=4, SPEED:Int32=256
    init(_ library:String,_ ephe:String)throws {
        guard let hh=dlopen(library,RTLD_NOW|RTLD_LOCAL) else { throw ForgeError.dl(String(cString:dlerror())) }; h=hh
        func sym<T>(_ n:String,_ t:T.Type)throws->T { guard let s=dlsym(hh,n) else {throw ForgeError.dl("missing \(n)")}; return unsafeBitCast(s,to:T.self) }
        let set:SetPath=try sym("swe_set_ephe_path",SetPath.self)
        calc=try sym("swe_calc_ut",CalcUT.self)
        solarWhen=try sym("swe_sol_eclipse_when_glob",SolarWhen.self)
        lunarWhen=try sym("swe_lun_eclipse_when",LunarWhen.self)
        solarWhere=try sym("swe_sol_eclipse_where",SolarWhere.self)
        lunarHow=try sym("swe_lun_eclipse_how",LunarHow.self)
        let vf:VersionFn=try sym("swe_version",VersionFn.self)
        ephe.withCString{set($0)}
        var b=[CChar](repeating:0,count:128); _=b.withUnsafeMutableBufferPointer{vf($0.baseAddress)}; version=String(cString:b)
    }
    deinit{dlclose(h)}
    func state(_ body:Int32,_ jd:Double)throws->State {
        var xx=[Double](repeating:0,count:6), err=[CChar](repeating:0,count:256)
        let f=xx.withUnsafeMutableBufferPointer{xp in err.withUnsafeMutableBufferPointer{ep in calc(jd,body,Swiss.SWIEPH|Swiss.SPEED,xp.baseAddress,ep.baseAddress)}}
        if f<0 || (f&Swiss.SWIEPH)==0 || (f&Swiss.MOSEPH) != 0 { throw ForgeError.swiss("body \(body) @ \(jd): \(String(cString:err)); flags=\(f)") }
        return State(longitude:norm(xx[0]),speed:xx[3])
    }
}

struct Event {
    let degree:Double, kind:String, type:String, centrality:String
    let phaseJD:Double, greatestJD:Double, magnitude:Double
    let secondary:Double?
}

let signs=["Aries","Taurus","Gemini","Cancer","Leo","Virgo","Libra","Scorpio","Sagittarius","Capricorn","Aquarius","Pisces"]
func degreeLabel(_ d:Double)->String {
    let within=norm(d).truncatingRemainder(dividingBy:30)
    var total=Int((within*3600).rounded())
    if total>=108000 { total=107999 }
    let deg=total/3600, min=(total%3600)/60, sec=total%60
    return String(format:"%02d°%02d'%02d\" %@",deg,min,sec,signs[Int(norm(d)/30)])
}
func utc(_ jd:Double)->String {
    let seconds=(jd-2440587.5)*86400.0
    let date=Date(timeIntervalSince1970:seconds)
    let f=ISO8601DateFormatter(); f.formatOptions=[.withInternetDateTime]; f.timeZone=TimeZone(secondsFromGMT:0)
    return f.string(from:date)
}
func phaseRoot(_ sw:Swiss,_ greatest:Double,_ lunar:Bool)throws->(Double,State,State,Double) {
    let target=lunar ? 180.0 : 0.0
    var x=greatest, bestJD=x, bestErr=Double.greatestFiniteMagnitude
    var bestSun=try sw.state(0,x), bestMoon=try sw.state(1,x)
    for _ in 0..<24 {
        let sun=try sw.state(0,x), moon=try sw.state(1,x)
        let e=signed180(norm(moon.longitude-sun.longitude)-target)
        if abs(e)<bestErr { bestErr=abs(e);bestJD=x;bestSun=sun;bestMoon=moon }
        if abs(e)<1e-10 { return(x,sun,moon,abs(e)*3600) }
        let speed=moon.speed-sun.speed
        if abs(speed)<1e-9 { break }
        let step=e/speed
        if !step.isFinite || abs(step)>1.0 { break }
        x -= step
    }
    if bestErr*3600 >= 0.001 { throw ForgeError.root("phase residual \(bestErr*3600) arcsec near JD \(greatest)") }
    return(bestJD,bestSun,bestMoon,bestErr*3600)
}
func solarType(_ flags:Int32)->String {
    if (flags & 32) != 0 { return "hybrid" }
    if (flags & 4) != 0 { return "total" }
    if (flags & 8) != 0 { return "annular" }
    return "partial"
}
func lunarType(_ flags:Int32)->String {
    if (flags & 4) != 0 { return "total" }
    if (flags & 16) != 0 { return "partial" }
    return "penumbral"
}
func parseArgs()throws->(String,String,String,Double,Double) {
    var lib:String?,ephe:String?,out:String?,start:Double?,end:Double?;let a=CommandLine.arguments;var i=1
    while i<a.count {switch a[i]{case"--library":i+=1;lib=a[i];case"--ephe-dir":i+=1;ephe=a[i];case"--output":i+=1;out=a[i];case"--start-jd":i+=1;start=Double(a[i]);case"--end-jd":i+=1;end=Double(a[i]);default:break};i+=1}
    guard let l=lib,let e=ephe,let o=out,let s=start,let n=end,s<n else {throw ForgeError.usage("required: --library --ephe-dir --output --start-jd --end-jd")};return(l,e,o,s,n)
}

func main()throws {
    let(lib,ephe,out,start,end)=try parseArgs(), sw=try Swiss(lib,ephe)
    guard sw.version=="2.10.03" else {throw ForgeError.swiss("unexpected Swiss \(sw.version)")}
    var events:[Event]=[]
    var cursor=start-2.0
    while true {
        var tret=[Double](repeating:0,count:10),err=[CChar](repeating:0,count:256)
        let flags=tret.withUnsafeMutableBufferPointer{tp in err.withUnsafeMutableBufferPointer{ep in sw.solarWhen(cursor,Swiss.SWIEPH,0,tp.baseAddress,0,ep.baseAddress)}}
        if flags<0 {throw ForgeError.swiss("solar search: \(String(cString:err))")}
        let greatest=tret[0]; if greatest>=end+2 {break}
        let q=try phaseRoot(sw,greatest,false)
        if q.0>=start && q.0<end {
            var geo=[Double](repeating:0,count:10),attr=[Double](repeating:0,count:20),serr=[CChar](repeating:0,count:256)
            let wf=geo.withUnsafeMutableBufferPointer{gp in attr.withUnsafeMutableBufferPointer{ap in serr.withUnsafeMutableBufferPointer{sp in sw.solarWhere(greatest,Swiss.SWIEPH,gp.baseAddress,ap.baseAddress,sp.baseAddress)}}}
            if wf<0 {throw ForgeError.swiss("solar where: \(String(cString:serr))")}
            let central=(flags&1) != 0 ? "central" : "noncentral"
            events.append(Event(degree:q.1.longitude,kind:"solar",type:solarType(flags),centrality:central,phaseJD:q.0,greatestJD:greatest,magnitude:attr[0],secondary:nil))
        }
        cursor=greatest+1.0
    }
    cursor=start-2.0
    while true {
        var tret=[Double](repeating:0,count:10),err=[CChar](repeating:0,count:256)
        let flags=tret.withUnsafeMutableBufferPointer{tp in err.withUnsafeMutableBufferPointer{ep in sw.lunarWhen(cursor,Swiss.SWIEPH,0,tp.baseAddress,0,ep.baseAddress)}}
        if flags<0 {throw ForgeError.swiss("lunar search: \(String(cString:err))")}
        let greatest=tret[0]; if greatest>=end+2 {break}
        let q=try phaseRoot(sw,greatest,true)
        if q.0>=start && q.0<end {
            var geo=[Double](repeating:0,count:10),attr=[Double](repeating:0,count:20),serr=[CChar](repeating:0,count:256)
            let hf=geo.withUnsafeMutableBufferPointer{gp in attr.withUnsafeMutableBufferPointer{ap in serr.withUnsafeMutableBufferPointer{sp in sw.lunarHow(greatest,Swiss.SWIEPH,gp.baseAddress,ap.baseAddress,sp.baseAddress)}}}
            if hf<0 {throw ForgeError.swiss("lunar how: \(String(cString:serr))")}
            events.append(Event(degree:q.2.longitude,kind:"lunar",type:lunarType(flags),centrality:"",phaseJD:q.0,greatestJD:greatest,magnitude:attr[0],secondary:attr[1]))
        }
        cursor=greatest+1.0
    }
    events.sort { abs($0.degree-$1.degree)>1e-12 ? $0.degree<$1.degree : $0.phaseJD<$1.phaseJD }
    let url=URL(fileURLWithPath:out);FileManager.default.createFile(atPath:url.path,contents:nil);let h=try FileHandle(forWritingTo:url);defer{try? h.close()}
    let header="eclipse_degree,degree_label,sign,degree_in_sign,eclipse_kind,eclipse_type,centrality,phase_jd_ut,phase_utc,greatest_eclipse_jd_ut,greatest_eclipse_utc,magnitude,secondary_magnitude\n";try h.write(contentsOf:header.data(using:.utf8)!)
    var solar=0,lunar=0
    for e in events {
        let si=Int(norm(e.degree)/30),within=norm(e.degree)-Double(si)*30
        let secondary=e.secondary.map{String(format:"%.6f",$0)} ?? ""
        let line=[String(format:"%.10f",norm(e.degree)),degreeLabel(e.degree),signs[si],String(format:"%.10f",within),e.kind,e.type,e.centrality,String(format:"%.9f",e.phaseJD),utc(e.phaseJD),String(format:"%.9f",e.greatestJD),utc(e.greatestJD),String(format:"%.6f",e.magnitude),secondary].joined(separator:",")+"\n"
        try h.write(contentsOf:line.data(using:.utf8)!)
        if e.kind=="solar"{solar+=1}else{lunar+=1}
    }
    print("PASS eclipse forge Swiss=\(sw.version) start=\(start) end=\(end) total=\(events.count) solar=\(solar) lunar=\(lunar)")
}

do{try main()}catch{fputs("ZeitgeistEclipseForge failed: \(error)\n",stderr);exit(1)}
