#!/usr/bin/env swift
import Foundation

enum POCError: Error, CustomStringConvertible {
    case usage(String)
    case malformed(String)
    var description: String {
        switch self {
        case .usage(let message), .malformed(let message): return message
        }
    }
}

struct CrossingHit { let motion: String; let boundaryID: Int }
struct CellHit { let motion: String; let segmentID: Int }

struct CelestialWeb {
    let boundaries: [[String: Any]]
    let vertebrae: [[String: Any]]
    let nerves: [String: Any]
    let tracts: [String: Any]
    let bounds: [String: Any]

    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let anatomy = root["anatomy"] as? [String: Any],
              let bone = anatomy["bone"] as? [String: Any],
              let boundaries = bone["boundaries"] as? [[String: Any]],
              let vertebrae = bone["vertebrae"] as? [[String: Any]],
              let nerves = anatomy["nerves"] as? [String: Any],
              let tracts = anatomy["tracts"] as? [String: Any],
              let bounds = root["celestialBounds"] as? [String: Any] else {
            throw POCError.malformed("Specimen does not match the celestial-web POC schema.")
        }
        self.boundaries = boundaries
        self.vertebrae = vertebrae
        self.nerves = nerves
        self.tracts = tracts
        self.bounds = bounds
    }

    func exactCrossings(body: String, degree: Int) -> [CrossingHit] {
        guard let index = nerves["degreeCrossingIndex"] as? [String: Any],
              let bodyIndex = index[body] as? [String: Any],
              let degreeIndex = bodyIndex[String(degree)] as? [String: Any] else { return [] }
        var hits: [CrossingHit] = []
        for motion in ["direct", "retrograde"] {
            for id in degreeIndex[motion] as? [Int] ?? [] {
                hits.append(.init(motion: motion, boundaryID: id))
            }
        }
        return hits.sorted { $0.boundaryID < $1.boundaryID }
    }

    func cellSegments(body: String, degree: Int) -> [CellHit] {
        guard let index = nerves["longitudeCellIndex"] as? [String: Any],
              let bodyIndex = index[body] as? [String: Any],
              let degreeIndex = bodyIndex[String(degree)] as? [String: Any] else { return [] }
        var hits: [CellHit] = []
        for motion in ["direct", "retrograde"] {
            for id in degreeIndex[motion] as? [Int] ?? [] {
                hits.append(.init(motion: motion, segmentID: id))
            }
        }
        return hits.sorted { $0.segmentID < $1.segmentID }
    }

    func segments(for body: String) throws -> [[String: Any]] {
        guard let bodyTract = tracts[body] as? [String: Any],
              let segments = bodyTract["segments"] as? [[String: Any]] else {
            throw POCError.malformed("No tract for \(body).")
        }
        return segments
    }

    func segment(body: String, id: Int) throws -> [String: Any] {
        let all = try segments(for: body)
        guard all.indices.contains(id) else { throw POCError.malformed("Missing \(body) tract segment \(id).") }
        return all[id]
    }

    func vertebrae(startBoundary: Int, endBoundary: Int) -> [[String: Any]] {
        vertebrae.filter {
            guard let start = $0["startBoundary"] as? Int,
                  let end = $0["endBoundary"] as? Int else { return false }
            return start >= startBoundary && end <= endBoundary
        }
    }

    func crossSection(boundaryID: Int) throws -> [String: Int] {
        guard let vertebra = vertebrae.first(where: { ($0["startBoundary"] as? Int) == boundaryID }),
              let refs = vertebra["tractRefs"] as? [String: Int] else {
            throw POCError.malformed("No vertebra starts at boundary \(boundaryID).")
        }
        return refs
    }
}

let signs = ["Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo", "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"]

func zodiac(_ absoluteDegree: Int) -> String {
    let normalized = ((absoluteDegree % 360) + 360) % 360
    return "\(normalized % 30)° \(signs[normalized / 30])"
}

func zodiac(_ value: Double) -> String {
    var normalized = value.truncatingRemainder(dividingBy: 360)
    if normalized < 0 { normalized += 360 }
    let signIndex = min(11, Int(normalized / 30))
    return String(format: "%.4f° %@", normalized - Double(signIndex * 30), signs[signIndex])
}

func civilReadout(jd: Double) -> String {
    let unix = (jd - 2_440_587.5) * 86_400
    let date = Date(timeIntervalSince1970: unix)
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter.string(from: date)
}

func int(_ dict: [String: Any], _ key: String) throws -> Int {
    guard let value = dict[key] as? Int else { throw POCError.malformed("Missing Int \(key).") }
    return value
}
func double(_ dict: [String: Any], _ key: String) throws -> Double {
    guard let value = dict[key] as? Double else { throw POCError.malformed("Missing Double \(key).") }
    return value
}
func string(_ dict: [String: Any], _ key: String) throws -> String {
    guard let value = dict[key] as? String else { throw POCError.malformed("Missing String \(key).") }
    return value
}
func uniqueOrdered<T: Hashable>(_ values: [T]) -> [T] {
    var seen = Set<T>()
    return values.filter { seen.insert($0).inserted }
}
func describeCells(_ cells: [Int]) -> String {
    let unique = uniqueOrdered(cells)
    if unique.count <= 8 { return unique.map(zodiac).joined(separator: ", ") }
    return "\(zodiac(unique.first!)) → \(zodiac(unique.last!)) (\(unique.count) cells)"
}

func run() throws {
    let args = Array(CommandLine.arguments.dropFirst())
    guard let specimenPath = args.first else {
        throw POCError.usage("Usage: CelestialWebPOC.swift <specimen.json> [body] [absolute-degree]")
    }
    let body = args.count > 1 ? args[1] : "Mercury"
    let degree = args.count > 2 ? Int(args[2]) ?? 8 : 8
    guard (0..<360).contains(degree) else { throw POCError.usage("Degree must be 0...359.") }

    let web = try CelestialWeb(url: URL(fileURLWithPath: specimenPath))
    let allSegments = try web.segments(for: body)
    guard let firstSegment = allSegments.first else { throw POCError.malformed("Empty tract for \(body).") }

    print("CELESTIAL WEB POC")
    print("query = \(body) @ \(zodiac(degree))")
    print("primary coordinate = celestial condition")
    print("resolved addresses are printed secondarily\n")

    let crossings = web.exactCrossings(body: body, degree: degree)
    print("1. DEGREE NERVE → crossing boundaries")
    if crossings.isEmpty { print("   no crossings inside this bounded specimen") }
    for hit in crossings {
        let boundary = web.boundaries[hit.boundaryID]
        let jd = try double(boundary, "julianDay")
        print("   \(hit.motion): boundary \(hit.boundaryID), address JD \(String(format: "%.9f", jd)) [civil readout \(civilReadout(jd: jd))]")
    }

    let cellHits = web.cellSegments(body: body, degree: degree)
    print("\n2. LONGITUDE-CELL NERVE → occupied tracts")
    for hit in cellHits {
        let segment = try web.segment(body: body, id: hit.segmentID)
        let sb = try int(segment, "startBoundary")
        let eb = try int(segment, "endBoundary")
        let startLon = try double(segment, "longitudeStart")
        let endLon = try double(segment, "longitudeEnd")
        print("   \(hit.motion): tract \(hit.segmentID), bone \(sb)..<\(eb), \(zodiac(startLon)) → \(zodiac(endLon))")
    }

    print("\n3. TRACT → BONE → every other body")
    for hit in cellHits {
        let segment = try web.segment(body: body, id: hit.segmentID)
        let sb = try int(segment, "startBoundary")
        let eb = try int(segment, "endBoundary")
        let covered = web.vertebrae(startBoundary: sb, endBoundary: eb)
        print("   \(body) tract \(hit.segmentID) [\(hit.motion)] spans \(covered.count) vertebrae")
        for other in web.tracts.keys.filter({ $0 != body }).sorted() {
            var refs: [Int] = []
            for vertebra in covered {
                if let tractRefs = vertebra["tractRefs"] as? [String: Int], let ref = tractRefs[other] { refs.append(ref) }
            }
            refs = uniqueOrdered(refs)
            let otherSegments = try web.segments(for: other)
            let cells = refs.compactMap { otherSegments.indices.contains($0) ? otherSegments[$0]["degreeCell"] as? Int : nil }
            print("      \(other): \(describeCells(cells))")
        }
    }

    print("\n4. BONE → CROSS-SECTION")
    if let firstCrossing = crossings.first {
        let refs = try web.crossSection(boundaryID: firstCrossing.boundaryID)
        print("   boundary \(firstCrossing.boundaryID) fans directly into \(refs.count) body tracts")
        for name in refs.keys.sorted() {
            let ref = refs[name]!
            let segment = try web.segment(body: name, id: ref)
            print("      \(name): tract \(ref), \(zodiac(try int(segment, "degreeCell"))), \(try string(segment, "motion"))")
        }
    }

    print("\n5. SPECIMEN-BOUNDARY TEST")
    let startLongitude = try double(firstSegment, "longitudeStart")
    let initialMotion = try string(firstSegment, "motion")
    print("   specimen opens with \(body) at \(zodiac(startLongitude)), \(initialMotion)")
    if body == "Mercury", degree == 8, crossings.count == 2, startLongitude > 8, startLongitude < 30, initialMotion == "direct" {
        print("   therefore the earlier direct pass through 8° Aries lies before the Sun=0° Aries anchor and is intentionally outside this specimen")
    }

    print("\nPOC LESSON")
    print("   exact whole-degree question: body → degree nerve → boundary")
    print("   occupancy question: body → longitude-cell nerve → tract")
    print("   relational question: tract → bone vertebrae → other-body tract refs")
    print("   motion question: motion nerve → tract run")
    print("   civil time is a resolved readout of the celestial path, not the query spine")
}

do { try run() }
catch {
    fputs("CelestialWebPOC error: \(error)\n", stderr)
    exit(1)
}
