import CryptoKit
import Foundation

/// The celestial matter Pollux is allowed to question. It carries forged supports and exact
/// station topology without exposing how that matter was manufactured or stored.
public struct SpineResonanceBodyMatter: Sendable {
    public let body: MundaneBody
    public let supportDegrees: Double
    public let supports: [OrboSpineCelestialCoordinate]
    public let stations: [OrboSpineStation]

    public init?(
        body: MundaneBody,
        supportDegrees: Double,
        supports: [OrboSpineCelestialCoordinate],
        stations: [OrboSpineStation]
    ) {
        guard supportDegrees.isFinite,
              supportDegrees > 0,
              supports.allSatisfy({ $0.body == body }),
              stations.allSatisfy({ $0.body == body }) else {
            return nil
        }
        self.body = body
        self.supportDegrees = supportDegrees
        self.supports = supports
        self.stations = stations
    }

    init(_ product: SpineForgeBodyProduct) {
        self.body = product.body
        self.supportDegrees = product.supportDegrees
        self.supports = product.supports
        self.stations = product.stations
    }
}

/// Pollux's independent source boundary. A resonance source is the durable or in-memory
/// matter from which a candidate Spine was forged, never the candidate runtime itself.
public protocol SpineResonanceSource: Sendable {
    var schematicIdentity: String { get }
    var schematicVersion: UInt16 { get }
    var astronomicalAuthority: String { get }
    var astronomicalSourceVersion: String { get }
    var bone: OrboSpineBoneSpan { get }
    var resonanceBodyOrder: [MundaneBody] { get }

    func resonanceBody(_ body: MundaneBody) -> SpineResonanceBodyMatter?
}

/// The live in-memory Forge product remains a valid Pollux source for manufacture ceremonies
/// and deterministic tests, but Pollux no longer depends on this concrete type.
extension SpineForgeProduct: SpineResonanceSource {
    public var resonanceBodyOrder: [MundaneBody] {
        bodies.map(\.body)
    }

    public func resonanceBody(_ body: MundaneBody) -> SpineResonanceBodyMatter? {
        self.body(body).map(SpineResonanceBodyMatter.init)
    }
}

public enum OrboSpineDurableCelestialResonanceSourceError: Error, Equatable {
    case missingFile(String)
    case malformedManifest
    case manifestMismatch
    case fileMismatch(String)
    case malformedCSV(String)
}

/// Pollux's production OrboSpine source. It reconstructs only celestial resonance matter
/// from the durable C4 supports/stations and verifies the manifest-bound bytes before use.
public struct OrboSpineDurableCelestialResonanceSource: SpineResonanceSource {
    public let schematicIdentity: String
    public let schematicVersion: UInt16
    public let astronomicalAuthority: String
    public let astronomicalSourceVersion: String
    public let bone: OrboSpineBoneSpan
    public let resonanceBodyOrder: [MundaneBody]

    private let bodiesByIdentity: [MundaneBody: SpineResonanceBodyMatter]

    public init(celestialDirectory: URL, schematic: SpineSchematic) throws {
        let manifestURL = celestialDirectory.appendingPathComponent("orbospine-celestial-manifest.json")
        guard FileManager.default.fileExists(atPath: manifestURL.path) else {
            throw OrboSpineDurableCelestialResonanceSourceError.missingFile(manifestURL.path)
        }

        let manifest: DurableManifest
        do {
            manifest = try JSONDecoder().decode(
                DurableManifest.self,
                from: Data(contentsOf: manifestURL)
            )
        } catch {
            throw OrboSpineDurableCelestialResonanceSourceError.malformedManifest
        }

        guard manifest.identity == schematic.identity,
              manifest.matterFormat == "directional-degree-csv",
              manifest.matterVersion == 1,
              manifest.astronomicalSource == schematic.astronomicalAuthority,
              manifest.astronomicalSourceVersion == schematic.astronomicalSourceVersion,
              same(manifest.supportedStartJulianDayUT, schematic.bone.start.value),
              same(manifest.supportedEndJulianDayUT, schematic.bone.end.value),
              manifest.bodies.count == schematic.bodyPlans.count else {
            throw OrboSpineDurableCelestialResonanceSourceError.manifestMismatch
        }

        var loaded: [MundaneBody: SpineResonanceBodyMatter] = [:]
        var order: [MundaneBody] = []
        order.reserveCapacity(manifest.bodies.count)

        for (index, report) in manifest.bodies.enumerated() {
            let plan = schematic.bodyPlans[index]
            guard let body = body(named: report.body),
                  body == plan.body,
                  report.supportDegrees == plan.supportDegrees,
                  report.astronomicalSourceVersion == schematic.astronomicalSourceVersion,
                  same(report.supportedStartJulianDayUT, schematic.bone.start.value),
                  same(report.supportedEndJulianDayUT, schematic.bone.end.value),
                  loaded[body] == nil else {
                throw OrboSpineDurableCelestialResonanceSourceError.manifestMismatch
            }

            let supportURL = celestialDirectory.appendingPathComponent(report.supportFile)
            let stationURL = celestialDirectory.appendingPathComponent(report.stationFile)
            try verify(
                supportURL,
                expectedBytes: report.supportFileBytes,
                expectedSHA256: report.supportSHA256
            )
            try verify(
                stationURL,
                expectedBytes: report.stationFileBytes,
                expectedSHA256: report.stationSHA256
            )

            let supports = try loadSupports(body: body, bone: schematic.bone, from: supportURL)
            let stations = try loadStations(body: body, bone: schematic.bone, from: stationURL)
            guard supports.count == report.supportRows,
                  stations.count == report.stationRows,
                  let matter = SpineResonanceBodyMatter(
                    body: body,
                    supportDegrees: report.supportDegrees,
                    supports: supports,
                    stations: stations
                  ) else {
                throw OrboSpineDurableCelestialResonanceSourceError.fileMismatch(report.body)
            }

            loaded[body] = matter
            order.append(body)
        }

        self.schematicIdentity = schematic.identity
        self.schematicVersion = schematic.version
        self.astronomicalAuthority = schematic.astronomicalAuthority
        self.astronomicalSourceVersion = schematic.astronomicalSourceVersion
        self.bone = schematic.bone
        self.resonanceBodyOrder = order
        self.bodiesByIdentity = loaded
    }

    public func resonanceBody(_ body: MundaneBody) -> SpineResonanceBodyMatter? {
        bodiesByIdentity[body]
    }
}

private extension OrboSpineDurableCelestialResonanceSource {
    struct DurableManifest: Decodable {
        let identity: String
        let matterFormat: String
        let matterVersion: Int
        let astronomicalSource: String
        let astronomicalSourceVersion: String
        let supportedStartJulianDayUT: Double
        let supportedEndJulianDayUT: Double
        let bodies: [DurableBodyReport]
    }

    struct DurableBodyReport: Decodable {
        let body: String
        let supportDegrees: Double
        let supportRows: Int
        let stationRows: Int
        let astronomicalSourceVersion: String
        let supportedStartJulianDayUT: Double
        let supportedEndJulianDayUT: Double
        let supportFile: String
        let supportFileBytes: Int64
        let supportSHA256: String
        let stationFile: String
        let stationFileBytes: Int64
        let stationSHA256: String
    }

    static let supportHeader =
        "directional_degree,physical_degree,navigation_cell,motion,jd_ut,civic_offset_seconds"
    static let stationHeader =
        "physical_degree,directional_degree_after,navigation_cell_after,lane_before,lane_after,jd_ut"
    static let epsilon = 1e-10

    static func body(named name: String) -> MundaneBody? {
        MundaneBody.allCases.first { $0.displayName == name }
    }

    static func verify(
        _ url: URL,
        expectedBytes: Int64,
        expectedSHA256: String
    ) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw OrboSpineDurableCelestialResonanceSourceError.missingFile(url.path)
        }
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        guard let size = attributes[.size] as? NSNumber,
              size.int64Value == expectedBytes,
              try sha256(url) == expectedSHA256 else {
            throw OrboSpineDurableCelestialResonanceSourceError.fileMismatch(url.lastPathComponent)
        }
    }

    static func loadSupports(
        body: MundaneBody,
        bone: OrboSpineBoneSpan,
        from url: URL
    ) throws -> [OrboSpineCelestialCoordinate] {
        let lines = try String(contentsOf: url, encoding: .utf8)
            .split(whereSeparator: \.isNewline)
        guard let first = lines.first, String(first) == supportHeader else {
            throw OrboSpineDurableCelestialResonanceSourceError.malformedCSV(url.lastPathComponent)
        }

        var supports: [OrboSpineCelestialCoordinate] = []
        supports.reserveCapacity(max(lines.count - 1, 0))
        var previousJD = -Double.infinity

        for rawLine in lines.dropFirst() {
            let fields = rawLine.split(separator: ",", omittingEmptySubsequences: false)
            guard fields.count == 6,
                  let directionalValue = Double(fields[0]),
                  let physical = Double(fields[1]),
                  let cell = Int(fields[2]),
                  let motion = Motion(rawValue: String(fields[3])),
                  let jdValue = Double(fields[4]),
                  let offset = Int64(fields[5]),
                  let directional = OrboSpineDirectionalDegree(directionalValue),
                  let julianDay = JulianDay(jdValue),
                  bone.contains(julianDay),
                  jdValue > previousJD,
                  abs(directional.physicalDegrees - physical) <= epsilon,
                  directional.navigationCell == cell,
                  directional.motion == motion,
                  offset == Int64(((jdValue - bone.start.value) * 86_400).rounded()) else {
                throw OrboSpineDurableCelestialResonanceSourceError.malformedCSV(url.lastPathComponent)
            }

            supports.append(OrboSpineCelestialCoordinate(
                body: body,
                directionalDegree: directional,
                julianDay: julianDay
            ))
            previousJD = jdValue
        }
        return supports
    }

    static func loadStations(
        body: MundaneBody,
        bone: OrboSpineBoneSpan,
        from url: URL
    ) throws -> [OrboSpineStation] {
        let lines = try String(contentsOf: url, encoding: .utf8)
            .split(whereSeparator: \.isNewline)
        guard let first = lines.first, String(first) == stationHeader else {
            throw OrboSpineDurableCelestialResonanceSourceError.malformedCSV(url.lastPathComponent)
        }

        var stations: [OrboSpineStation] = []
        stations.reserveCapacity(max(lines.count - 1, 0))
        var previousJD = -Double.infinity

        for rawLine in lines.dropFirst() {
            let fields = rawLine.split(separator: ",", omittingEmptySubsequences: false)
            guard fields.count == 6,
                  let physical = Double(fields[0]),
                  let directionalAfter = Double(fields[1]),
                  let cellAfter = Int(fields[2]),
                  let laneBefore = Motion(rawValue: String(fields[3])),
                  let laneAfter = Motion(rawValue: String(fields[4])),
                  let jdValue = Double(fields[5]),
                  let julianDay = JulianDay(jdValue),
                  bone.contains(julianDay),
                  jdValue > previousJD,
                  let station = OrboSpineStation(
                    body: body,
                    physicalDegrees: physical,
                    julianDay: julianDay,
                    laneBefore: laneBefore,
                    laneAfter: laneAfter
                  ),
                  abs(station.directionalDegreeAfter.degrees - directionalAfter) <= epsilon,
                  station.navigationCellAfter == cellAfter else {
                throw OrboSpineDurableCelestialResonanceSourceError.malformedCSV(url.lastPathComponent)
            }

            stations.append(station)
            previousJD = jdValue
        }
        return stations
    }

    static func sha256(_ url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var hasher = SHA256()
        while true {
            let data = try handle.read(upToCount: 1_048_576) ?? Data()
            if data.isEmpty { break }
            hasher.update(data: data)
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    static func same(_ lhs: Double, _ rhs: Double) -> Bool {
        abs(lhs - rhs) < 1e-12
    }
}