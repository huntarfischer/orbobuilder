import Foundation
#if canImport(CryptoKit)
import CryptoKit
#else
import Crypto
#endif

/// Stable binary representation of one finished universal OrboSpine.
///
/// The artifact carries already-forged Door I and Door II matter. Door III has no payload:
/// Link remains addressability over the same mounted Locate authority.
internal enum OrboSpineArtifactFormat {
    static let magic = Array("ORBSPN01".utf8)
    static let version: UInt16 = 1
    static let littleEndianMarker: UInt8 = 1
    static let headerSize = 32
    static let directoryEntrySize = 32

    enum Section: UInt32, CaseIterable {
        case metadata = 1
        case bodyDirectory = 2
        case segments = 3
        case navigationDirectory = 4
        case navigationIndices = 5
        case terra = 6
        case stations = 7
        case retrogradePassages = 8
        case ring = 9
        case eclipses = 10
        case shells = 11
    }
}

internal struct OrboSpineArtifactSegment: Hashable, Sendable {
    let start: JulianDay
    let end: JulianDay
    let startPhysicalDegrees: Double
    let endPhysicalDegrees: Double
    let motion: Motion
}

internal struct OrboSpineArtifactTract: Hashable, Sendable {
    let body: MundaneBody
    let segments: [OrboSpineArtifactSegment]
    /// Exactly 720 coarse navigation cells, each containing local segment indices.
    let segmentIndexesByCell: [[Int]]
}

internal struct OrboSpineArtifactMatter: Sendable {
    let schematicIdentity: String
    let schematicVersion: UInt16
    let bone: OrboSpineBoneSpan
    let candidateManifestSHA256: String
    let astronomicalAuthority: String
    let astronomicalSourceVersion: String
    let tracts: [OrboSpineArtifactTract]
    let terra: [TerraMarrowSample]
    let stations: [OrboSpineStation]
    let retrogradePassages: [OrboSpineRetrogradePassage]
    let ring: [OrboSpineRingOccurrence]
    let eclipses: [OrboSpineEclipseOccurrence]
    let shells: [OrboSpineShellInterval]
    let inventory: OrboSpineRuntimeInventory
}

public struct OrboSpineArtifactReceipt: Hashable, Sendable {
    public let sha256: String
    public let byteCount: Int
    public let formatVersion: UInt16
}

public enum OrboSpineArtifactError: Error, Equatable, Sendable {
    case malformedArtifact
    case unsupportedVersion(UInt16)
    case wrongByteOrder
    case invalidSectionDirectory
    case invalidMetadata
    case invalidBody(MundaneBody)
    case invalidNavigation
    case invalidRecord
    case outsideBone
    case bodyUnavailable(MundaneBody)
    case invalidNavigationCell(Int)
    case terraUnavailable
    case invalidMatter
    case artifactIdentityMismatch(expected: String, actual: String)
}

/// Read-only mounted view of the finished bytes. `Data(..., .mappedIfSafe)` allows the operating
/// system to page sections on demand; parsing the header does not materialize Ring chronology.
internal final class OrboSpineMountedArtifact: @unchecked Sendable {
    private final class LibraryCache {
        let lock = NSLock()
        var stations: Result<[OrboSpineStation], Error>?
        var retrogradePassages: Result<[OrboSpineRetrogradePassage], Error>?
        var ring: Result<[OrboSpineRingOccurrence], Error>?
        var eclipses: Result<[OrboSpineEclipseOccurrence], Error>?
        var shells: Result<[OrboSpineShellInterval], Error>?
    }

    struct Metadata: Sendable {
        let schematicIdentity: String
        let schematicVersion: UInt16
        let bone: OrboSpineBoneSpan
        let candidateManifestSHA256: String
        let astronomicalAuthority: String
        let astronomicalSourceVersion: String
        let inventory: OrboSpineRuntimeInventory
    }

    private struct DirectoryEntry: Sendable {
        let recordSize: UInt32
        let offset: Int
        let byteLength: Int
        let recordCount: Int
    }

    private struct BodyEntry: Sendable {
        let body: MundaneBody
        let segmentStart: Int
        let segmentCount: Int
        let navigationCellStart: Int
    }

    private struct NavigationEntry: Sendable {
        let indexStart: Int
        let count: Int
    }

    let data: Data
    let sha256: String
    let metadata: Metadata
    private let sections: [OrboSpineArtifactFormat.Section: DirectoryEntry]
    private let bodies: [MundaneBody: BodyEntry]
    private let libraryCache = LibraryCache()

    convenience init(url: URL) throws {
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        try self.init(data: data)
    }

    init(data: Data) throws {
        guard data.count >= OrboSpineArtifactFormat.headerSize else {
            throw OrboSpineArtifactError.malformedArtifact
        }
        var reader = BinaryReader(data: data, offset: 0, limit: data.count)
        guard try reader.bytes(count: 8) == OrboSpineArtifactFormat.magic else {
            throw OrboSpineArtifactError.malformedArtifact
        }
        let version = try reader.u16()
        guard version == OrboSpineArtifactFormat.version else {
            throw OrboSpineArtifactError.unsupportedVersion(version)
        }
        guard try reader.u8() == OrboSpineArtifactFormat.littleEndianMarker else {
            throw OrboSpineArtifactError.wrongByteOrder
        }
        _ = try reader.u8()
        let sectionCount = Int(try reader.u32())
        guard let directoryOffset = Int(exactly: try reader.u64()) else {
            throw OrboSpineArtifactError.invalidSectionDirectory
        }
        let directoryEntrySize = Int(try reader.u32())
        let headerSize = Int(try reader.u32())
        guard headerSize == OrboSpineArtifactFormat.headerSize,
              directoryEntrySize == OrboSpineArtifactFormat.directoryEntrySize,
              sectionCount == OrboSpineArtifactFormat.Section.allCases.count,
              directoryOffset >= headerSize,
              directoryOffset + sectionCount * directoryEntrySize <= data.count else {
            throw OrboSpineArtifactError.invalidSectionDirectory
        }

        var directoryReader = BinaryReader(
            data: data,
            offset: directoryOffset,
            limit: directoryOffset + sectionCount * directoryEntrySize
        )
        var sections: [OrboSpineArtifactFormat.Section: DirectoryEntry] = [:]
        for _ in 0..<sectionCount {
            guard let section = OrboSpineArtifactFormat.Section(rawValue: try directoryReader.u32()) else {
                throw OrboSpineArtifactError.invalidSectionDirectory
            }
            let recordSize = try directoryReader.u32()
            guard let offset = Int(exactly: try directoryReader.u64()),
                  let byteLength = Int(exactly: try directoryReader.u64()),
                  let recordCount = Int(exactly: try directoryReader.u64()) else {
                throw OrboSpineArtifactError.invalidSectionDirectory
            }
            guard sections[section] == nil,
                  offset >= directoryOffset + sectionCount * directoryEntrySize,
                  byteLength >= 0,
                  offset <= data.count,
                  byteLength <= data.count - offset,
                  recordCount >= 0 else {
                throw OrboSpineArtifactError.invalidSectionDirectory
            }
            if recordSize > 0 {
                guard recordCount == 0
                        ? byteLength == 0
                        : byteLength % recordCount == 0
                            && byteLength / recordCount == Int(recordSize) else {
                    throw OrboSpineArtifactError.invalidSectionDirectory
                }
            }
            sections[section] = DirectoryEntry(
                recordSize: recordSize,
                offset: offset,
                byteLength: byteLength,
                recordCount: recordCount
            )
        }
        guard sections.count == OrboSpineArtifactFormat.Section.allCases.count else {
            throw OrboSpineArtifactError.invalidSectionDirectory
        }
        let orderedSections = sections.values.sorted { $0.offset < $1.offset }
        var previousEnd = directoryOffset + sectionCount * directoryEntrySize
        for section in orderedSections {
            guard section.offset >= previousEnd else {
                throw OrboSpineArtifactError.invalidSectionDirectory
            }
            previousEnd = section.offset + section.byteLength
        }
        guard previousEnd == data.count else {
            throw OrboSpineArtifactError.invalidSectionDirectory
        }

        let metadata = try Self.readMetadata(data: data, section: sections[.metadata]!)
        let bodyEntries = try Self.readBodyDirectory(data: data, section: sections[.bodyDirectory]!)
        guard Set(bodyEntries.map(\.body)) == Set(MundaneBody.canonicalOrder) else {
            throw OrboSpineArtifactError.invalidSectionDirectory
        }
        let bodyMap = Dictionary(uniqueKeysWithValues: bodyEntries.map { ($0.body, $0) })
        try Self.validateBodyRanges(
            bodyMap,
            segmentSection: sections[.segments]!,
            navigationSection: sections[.navigationDirectory]!
        )
        try Self.validateInventory(metadata.inventory, sections: sections)

        self.data = data
        self.sha256 = Self.sha256Hex(data)
        self.metadata = metadata
        self.sections = sections
        self.bodies = bodyMap
    }

    // MARK: Locate

    func coordinate(of body: MundaneBody, at julianDay: JulianDay) throws -> OrboSpineCelestialCoordinate {
        guard metadata.bone.contains(julianDay) else { throw OrboSpineArtifactError.outsideBone }
        guard let bodyEntry = bodies[body], bodyEntry.segmentCount > 0 else {
            throw OrboSpineArtifactError.bodyUnavailable(body)
        }
        var low = 0
        var high = bodyEntry.segmentCount
        while low < high {
            let middle = (low + high) / 2
            let segment = try readSegment(globalIndex: bodyEntry.segmentStart + middle)
            if segment.end.value <= julianDay.value {
                low = middle + 1
            } else {
                high = middle
            }
        }
        let localIndex = min(low, bodyEntry.segmentCount - 1)
        let segment = try readSegment(globalIndex: bodyEntry.segmentStart + localIndex)
        let fraction = (julianDay.value - segment.start.value) / (segment.end.value - segment.start.value)
        let distance = directionalDistance(
            from: segment.startPhysicalDegrees,
            to: segment.endPhysicalDegrees,
            motion: segment.motion
        ) * fraction
        let physical = move(from: segment.startPhysicalDegrees, by: distance, motion: segment.motion)
        guard let directional = OrboSpineDirectionalDegree(physicalDegrees: physical, motion: segment.motion) else {
            throw OrboSpineArtifactError.invalidRecord
        }
        return OrboSpineCelestialCoordinate(body: body, directionalDegree: directional, julianDay: julianDay)
    }

    func occurrences(
        of body: MundaneBody,
        at directionalDegree: OrboSpineDirectionalDegree
    ) throws -> [OrboSpineCelestialCoordinate] {
        guard let bodyEntry = bodies[body] else { throw OrboSpineArtifactError.bodyUnavailable(body) }
        let localIndices = try navigationIndices(bodyEntry: bodyEntry, cell: directionalDegree.navigationCell)
        var result: [OrboSpineCelestialCoordinate] = []
        result.reserveCapacity(localIndices.count)
        for localIndex in localIndices {
            guard localIndex >= 0, localIndex < bodyEntry.segmentCount else {
                throw OrboSpineArtifactError.invalidNavigation
            }
            let segment = try readSegment(globalIndex: bodyEntry.segmentStart + localIndex)
            guard segment.motion == directionalDegree.motion else { continue }
            let targetDistance = directionalDistance(
                from: segment.startPhysicalDegrees,
                to: directionalDegree.physicalDegrees,
                motion: segment.motion
            )
            let segmentDistance = directionalDistance(
                from: segment.startPhysicalDegrees,
                to: segment.endPhysicalDegrees,
                motion: segment.motion
            )
            guard targetDistance < segmentDistance - Self.epsilon || targetDistance <= Self.epsilon else {
                continue
            }
            let fraction = targetDistance / segmentDistance
            let value = segment.start.value + (segment.end.value - segment.start.value) * fraction
            guard value >= metadata.bone.start.value - Self.epsilon,
                  value < metadata.bone.end.value - Self.epsilon,
                  let julianDay = JulianDay(value) else { continue }
            result.append(OrboSpineCelestialCoordinate(
                body: body,
                directionalDegree: directionalDegree,
                julianDay: julianDay
            ))
        }
        result.sort { $0.julianDay.value < $1.julianDay.value }
        var deduplicated: [OrboSpineCelestialCoordinate] = []
        for occurrence in result {
            if let previous = deduplicated.last,
               abs(previous.julianDay.value - occurrence.julianDay.value) <= Self.epsilon {
                continue
            }
            deduplicated.append(occurrence)
        }
        return deduplicated
    }

    func candidateWindows(of body: MundaneBody, inNavigationCell cell: Int) throws -> [OrboSpineBoneSpan] {
        guard (0..<720).contains(cell) else { throw OrboSpineArtifactError.invalidNavigationCell(cell) }
        guard let bodyEntry = bodies[body] else { throw OrboSpineArtifactError.bodyUnavailable(body) }
        return try navigationIndices(bodyEntry: bodyEntry, cell: cell).compactMap { localIndex in
            guard localIndex >= 0, localIndex < bodyEntry.segmentCount else {
                throw OrboSpineArtifactError.invalidNavigation
            }
            let segment = try readSegment(globalIndex: bodyEntry.segmentStart + localIndex)
            return OrboSpineBoneSpan(start: segment.start, end: segment.end)
        }
    }

    func terra(at julianDay: JulianDay) throws -> TerraMarrowSample {
        guard metadata.bone.contains(julianDay) else { throw OrboSpineArtifactError.outsideBone }
        let section = sections[.terra]!
        guard section.recordCount >= 2 else { throw OrboSpineArtifactError.terraUnavailable }

        if let exact = try exactTerraSample(value: julianDay.value, section: section) { return exact }

        let bounds = try terraSourceRegionBounds(value: julianDay.value, section: section)
        let insertion = try terraLowerBound(julianDay.value, low: bounds.lowerBound, high: bounds.upperBound, section: section)
        let lowerIndex: Int
        let upperIndex: Int
        if insertion <= bounds.lowerBound {
            lowerIndex = bounds.lowerBound
            upperIndex = min(bounds.lowerBound + 1, bounds.upperBound - 1)
        } else if insertion >= bounds.upperBound {
            upperIndex = bounds.upperBound - 1
            lowerIndex = max(bounds.lowerBound, upperIndex - 1)
        } else {
            lowerIndex = insertion - 1
            upperIndex = insertion
        }
        let lower = try readTerra(index: lowerIndex)
        let upper = try readTerra(index: upperIndex)
        let fraction = (julianDay.value - lower.julianDay.value) / (upper.julianDay.value - lower.julianDay.value)
        let turnTravel = normalized(upper.turnDegrees - lower.turnDegrees)
        let turn = normalized(lower.turnDegrees + turnTravel * fraction)
        let tilt = lower.tiltDegrees + (upper.tiltDegrees - lower.tiltDegrees) * fraction
        guard let sample = TerraMarrowSample(turnDegrees: turn, tiltDegrees: tilt, julianDay: julianDay) else {
            throw OrboSpineArtifactError.invalidRecord
        }
        return sample
    }

    // MARK: Library

    func allStations() throws -> [OrboSpineStation] {
        try cached(\.stations) {
            try decodeFixed(section: .stations, recordSize: 24, decode: readStation)
        }
    }

    func allRetrogradePassages() throws -> [OrboSpineRetrogradePassage] {
        try cached(\.retrogradePassages) {
            try decodeFixed(section: .retrogradePassages, recordSize: 40, decode: readRetrogradePassage)
        }
    }

    func allRingOccurrences() throws -> [OrboSpineRingOccurrence] {
        try cached(\.ring) {
            try decodeFixed(section: .ring, recordSize: 32, decode: readRingOccurrence)
        }
    }

    func allEclipses() throws -> [OrboSpineEclipseOccurrence] {
        try cached(\.eclipses) { try decodeEclipses() }
    }

    private func decodeEclipses() throws -> [OrboSpineEclipseOccurrence] {
        let section = sections[.eclipses]!
        var reader = BinaryReader(data: data, offset: section.offset, limit: section.offset + section.byteLength)
        var rows: [OrboSpineEclipseOccurrence] = []
        rows.reserveCapacity(section.recordCount)
        for _ in 0..<section.recordCount {
            let kindByte = try reader.u8()
            let typeByte = try reader.u8()
            let flags = try reader.u8()
            _ = try reader.u8()
            let degree = try reader.double()
            let julianDayValue = try reader.double()
            let greatest = try reader.double()
            let magnitude = try reader.double()
            let secondary = try reader.double()
            let centralityLength = Int(try reader.u32())
            let centralityBytes = try reader.bytes(count: centralityLength)
            let centrality: String?
            if centralityBytes.isEmpty {
                centrality = nil
            } else {
                guard let value = String(bytes: centralityBytes, encoding: .utf8) else {
                    throw OrboSpineArtifactError.invalidRecord
                }
                centrality = value
            }
            guard let kind = decodeEclipseKind(kindByte),
                  let type = decodeEclipseType(typeByte),
                  let jd = JulianDay(julianDayValue),
                  let row = OrboSpineEclipseOccurrence(
                    kind: kind,
                    type: type,
                    eclipseDegree: degree,
                    julianDay: jd,
                    greatestEclipseJulianDay: flags & 0x01 == 0 ? nil : JulianDay(greatest),
                    magnitude: flags & 0x02 == 0 ? nil : magnitude,
                    secondaryMagnitude: flags & 0x04 == 0 ? nil : secondary,
                    centrality: centrality
                  ) else {
                throw OrboSpineArtifactError.invalidRecord
            }
            rows.append(row)
        }
        guard reader.isAtEnd else { throw OrboSpineArtifactError.invalidRecord }
        return rows
    }

    func allShells() throws -> [OrboSpineShellInterval] {
        try cached(\.shells) {
            try decodeFixed(section: .shells, recordSize: 24, decode: readShell)
        }
    }

    private func cached<T>(
        _ keyPath: ReferenceWritableKeyPath<LibraryCache, Result<[T], Error>?>,
        load: () throws -> [T]
    ) throws -> [T] {
        libraryCache.lock.lock()
        defer { libraryCache.lock.unlock() }
        if let result = libraryCache[keyPath: keyPath] { return try result.get() }
        let result = Result(catching: load)
        libraryCache[keyPath: keyPath] = result
        return try result.get()
    }

    // MARK: Binary reads

    private func readSegment(globalIndex: Int) throws -> OrboSpineArtifactSegment {
        let section = sections[.segments]!
        guard section.recordSize == 40, globalIndex >= 0, globalIndex < section.recordCount else {
            throw OrboSpineArtifactError.invalidRecord
        }
        var reader = BinaryReader(
            data: data,
            offset: section.offset + globalIndex * 40,
            limit: section.offset + (globalIndex + 1) * 40
        )
        guard let start = JulianDay(try reader.double()),
              let end = JulianDay(try reader.double()),
              let motion = decodeMotion(try reader.u8()) else {
            throw OrboSpineArtifactError.invalidRecord
        }
        _ = try reader.bytes(count: 7)
        let startPhysical = try reader.double()
        let endPhysical = try reader.double()
        guard start.value < end.value,
              startPhysical >= 0, startPhysical < 360,
              endPhysical >= 0, endPhysical < 360 else {
            throw OrboSpineArtifactError.invalidRecord
        }
        return OrboSpineArtifactSegment(
            start: start,
            end: end,
            startPhysicalDegrees: startPhysical,
            endPhysicalDegrees: endPhysical,
            motion: motion
        )
    }

    private func navigationIndices(bodyEntry: BodyEntry, cell: Int) throws -> [Int] {
        guard (0..<720).contains(cell) else { throw OrboSpineArtifactError.invalidNavigationCell(cell) }
        let navSection = sections[.navigationDirectory]!
        let navIndex = bodyEntry.navigationCellStart + cell
        guard navSection.recordSize == 16, navIndex >= 0, navIndex < navSection.recordCount else {
            throw OrboSpineArtifactError.invalidNavigation
        }
        var reader = BinaryReader(
            data: data,
            offset: navSection.offset + navIndex * 16,
            limit: navSection.offset + (navIndex + 1) * 16
        )
        guard let indexStart = Int(exactly: try reader.u64()),
              let count = Int(exactly: try reader.u32()) else {
            throw OrboSpineArtifactError.invalidNavigation
        }
        let entry = NavigationEntry(indexStart: indexStart, count: count)
        _ = try reader.u32()
        let indexSection = sections[.navigationIndices]!
        guard indexSection.recordSize == 8,
              entry.indexStart >= 0,
              entry.count >= 0,
              entry.indexStart <= indexSection.recordCount,
              entry.count <= indexSection.recordCount - entry.indexStart else {
            throw OrboSpineArtifactError.invalidNavigation
        }
        var indices: [Int] = []
        indices.reserveCapacity(entry.count)
        for index in 0..<entry.count {
            var indexReader = BinaryReader(
                data: data,
                offset: indexSection.offset + (entry.indexStart + index) * 8,
                limit: indexSection.offset + (entry.indexStart + index + 1) * 8
            )
            guard let value = Int(exactly: try indexReader.u64()) else {
                throw OrboSpineArtifactError.invalidNavigation
            }
            indices.append(value)
        }
        return indices
    }

    private func readTerra(index: Int) throws -> TerraMarrowSample {
        let section = sections[.terra]!
        guard section.recordSize == 24, index >= 0, index < section.recordCount else {
            throw OrboSpineArtifactError.invalidRecord
        }
        var reader = BinaryReader(
            data: data,
            offset: section.offset + index * 24,
            limit: section.offset + (index + 1) * 24
        )
        let jdValue = try reader.double()
        let turn = try reader.double()
        let tilt = try reader.double()
        guard let jd = JulianDay(jdValue),
              let sample = TerraMarrowSample(turnDegrees: turn, tiltDegrees: tilt, julianDay: jd) else {
            throw OrboSpineArtifactError.invalidRecord
        }
        return sample
    }

    private func exactTerraSample(value: Double, section: DirectoryEntry) throws -> TerraMarrowSample? {
        let index = try terraLowerBound(value, low: 0, high: section.recordCount, section: section)
        if index < section.recordCount {
            let sample = try readTerra(index: index)
            if abs(sample.julianDay.value - value) <= 1e-12 { return sample }
        }
        if index > 0 {
            let sample = try readTerra(index: index - 1)
            if abs(sample.julianDay.value - value) <= 1e-12 { return sample }
        }
        return nil
    }

    private func terraSourceRegionBounds(value: Double, section: DirectoryEntry) throws -> Range<Int> {
        let seams = TerraMarrowContract.sourceModelSeamJulianDays
        let first = seams[0]
        let second = seams[1]
        if value < first { return 0..<(try terraUpperBound(first, section: section)) }
        if value > first && value < second {
            return (try terraUpperBound(first, section: section))..<(try terraLowerBound(second, low: 0, high: section.recordCount, section: section))
        }
        if value > second {
            return (try terraLowerBound(second, low: 0, high: section.recordCount, section: section))..<section.recordCount
        }
        return 0..<section.recordCount
    }

    private func terraLowerBound(_ value: Double, low initialLow: Int, high initialHigh: Int, section: DirectoryEntry) throws -> Int {
        var low = initialLow
        var high = initialHigh
        while low < high {
            let middle = (low + high) / 2
            if try readTerra(index: middle).julianDay.value < value { low = middle + 1 } else { high = middle }
        }
        return low
    }

    private func terraUpperBound(_ value: Double, section: DirectoryEntry) throws -> Int {
        var low = 0
        var high = section.recordCount
        while low < high {
            let middle = (low + high) / 2
            if try readTerra(index: middle).julianDay.value <= value { low = middle + 1 } else { high = middle }
        }
        return low
    }

    private func decodeFixed<T>(
        section id: OrboSpineArtifactFormat.Section,
        recordSize: Int,
        decode: (inout BinaryReader) throws -> T
    ) throws -> [T] {
        let section = sections[id]!
        guard section.recordSize == recordSize else { throw OrboSpineArtifactError.invalidRecord }
        var result: [T] = []
        result.reserveCapacity(section.recordCount)
        for index in 0..<section.recordCount {
            var reader = BinaryReader(
                data: data,
                offset: section.offset + index * recordSize,
                limit: section.offset + (index + 1) * recordSize
            )
            result.append(try decode(&reader))
            guard reader.isAtEnd else { throw OrboSpineArtifactError.invalidRecord }
        }
        return result
    }

    private func readStation(_ reader: inout BinaryReader) throws -> OrboSpineStation {
        guard let body = MundaneBody(rawValue: try reader.u8()),
              let before = decodeMotion(try reader.u8()),
              let after = decodeMotion(try reader.u8()) else { throw OrboSpineArtifactError.invalidRecord }
        _ = try reader.u8()
        _ = try reader.u32()
        let jdValue = try reader.double()
        let degree = try reader.double()
        guard let jd = JulianDay(jdValue),
              let station = OrboSpineStation(body: body, physicalDegrees: degree, julianDay: jd, laneBefore: before, laneAfter: after) else {
            throw OrboSpineArtifactError.invalidRecord
        }
        return station
    }

    private func readRetrogradePassage(_ reader: inout BinaryReader) throws -> OrboSpineRetrogradePassage {
        guard let body = MundaneBody(rawValue: try reader.u8()),
              let startBoundary = decodeRetrogradeBoundary(try reader.u8()),
              let endBoundary = decodeRetrogradeBoundary(try reader.u8()) else { throw OrboSpineArtifactError.invalidRecord }
        let flags = try reader.u8()
        _ = try reader.u32()
        let startValue = try reader.double()
        let endValue = try reader.double()
        let startDegree = try reader.double()
        let endDegree = try reader.double()
        guard let start = JulianDay(startValue), let end = JulianDay(endValue),
              let passage = OrboSpineRetrogradePassage(
                body: body,
                start: start,
                end: end,
                startStationPhysicalDegrees: flags & 0x01 == 0 ? nil : startDegree,
                endStationPhysicalDegrees: flags & 0x02 == 0 ? nil : endDegree,
                startBoundary: startBoundary,
                endBoundary: endBoundary
              ) else { throw OrboSpineArtifactError.invalidRecord }
        return passage
    }

    private func readRingOccurrence(_ reader: inout BinaryReader) throws -> OrboSpineRingOccurrence {
        guard let bodyA = MundaneBody(rawValue: try reader.u8()),
              let bodyB = MundaneBody(rawValue: try reader.u8()) else { throw OrboSpineArtifactError.invalidRecord }
        let markRaw = Int(try reader.u16())
        _ = try reader.u32()
        let a = try reader.double()
        let b = try reader.double()
        let jdValue = try reader.double()
        guard let mark = RingMark(rawValue: markRaw),
              let aDegree = OrboSpineDirectionalDegree(a),
              let bDegree = OrboSpineDirectionalDegree(b),
              let jd = JulianDay(jdValue),
              let occurrence = OrboSpineRingOccurrence(
                bodyA: bodyA,
                bodyB: bodyB,
                mark: mark,
                bodyADirectionalDegree: aDegree,
                bodyBDirectionalDegree: bDegree,
                julianDay: jd
              ) else { throw OrboSpineArtifactError.invalidRecord }
        return occurrence
    }

    private func readShell(_ reader: inout BinaryReader) throws -> OrboSpineShellInterval {
        guard let family = decodeShellFamily(try reader.u8()) else { throw OrboSpineArtifactError.invalidRecord }
        _ = try reader.bytes(count: 3)
        let ordinal = Int(try reader.u32())
        let startValue = try reader.double()
        let endValue = try reader.double()
        guard let id = OrboSpineShellID(family: family, ordinal: ordinal),
              let start = JulianDay(startValue), let end = JulianDay(endValue),
              let shell = OrboSpineShellInterval(id: id, start: start, end: end) else {
            throw OrboSpineArtifactError.invalidRecord
        }
        return shell
    }

    // MARK: Header validation

    private static func readMetadata(data: Data, section: DirectoryEntry) throws -> Metadata {
        var reader = BinaryReader(data: data, offset: section.offset, limit: section.offset + section.byteLength)
        let schematicIdentity = try reader.string()
        let schematicVersion = try reader.u16()
        _ = try reader.u16()
        let startValue = try reader.double()
        let endValue = try reader.double()
        let candidateManifestSHA256 = try reader.string()
        let authority = try reader.string()
        let sourceVersion = try reader.string()
        let counts = (try reader.u64(), try reader.u64(), try reader.u64(), try reader.u64(), try reader.u64(), try reader.u64(), try reader.u64())
        guard reader.isAtEnd,
              let start = JulianDay(startValue), let end = JulianDay(endValue),
              let bone = OrboSpineBoneSpan(start: start, end: end),
              !schematicIdentity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              schematicVersion > 0,
              candidateManifestSHA256.count == 64,
              candidateManifestSHA256.allSatisfy({ $0.isHexDigit }),
              !authority.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !sourceVersion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OrboSpineArtifactError.invalidMetadata
        }
        guard let celestialSupportCount = Int(exactly: counts.0),
              let stationCount = Int(exactly: counts.1),
              let retrogradePassageCount = Int(exactly: counts.2),
              let ringOccurrenceCount = Int(exactly: counts.3),
              let eclipseCount = Int(exactly: counts.4),
              let shellIntervalCount = Int(exactly: counts.5),
              let terraSampleCount = Int(exactly: counts.6) else {
            throw OrboSpineArtifactError.invalidMetadata
        }
        return Metadata(
            schematicIdentity: schematicIdentity,
            schematicVersion: schematicVersion,
            bone: bone,
            candidateManifestSHA256: candidateManifestSHA256.lowercased(),
            astronomicalAuthority: authority,
            astronomicalSourceVersion: sourceVersion,
            inventory: OrboSpineRuntimeInventory(
                celestialSupportCount: celestialSupportCount,
                stationCount: stationCount,
                retrogradePassageCount: retrogradePassageCount,
                ringOccurrenceCount: ringOccurrenceCount,
                eclipseCount: eclipseCount,
                shellIntervalCount: shellIntervalCount,
                terraSampleCount: terraSampleCount
            )
        )
    }

    private static func readBodyDirectory(data: Data, section: DirectoryEntry) throws -> [BodyEntry] {
        guard section.recordSize == 32 else { throw OrboSpineArtifactError.invalidSectionDirectory }
        var result: [BodyEntry] = []
        result.reserveCapacity(section.recordCount)
        for index in 0..<section.recordCount {
            var reader = BinaryReader(
                data: data,
                offset: section.offset + index * 32,
                limit: section.offset + (index + 1) * 32
            )
            guard let body = MundaneBody(rawValue: try reader.u8()) else { throw OrboSpineArtifactError.invalidRecord }
            _ = try reader.bytes(count: 7)
            guard let segmentStart = Int(exactly: try reader.u64()),
                  let segmentCount = Int(exactly: try reader.u64()),
                  let navigationCellStart = Int(exactly: try reader.u64()) else {
                throw OrboSpineArtifactError.invalidRecord
            }
            result.append(BodyEntry(
                body: body,
                segmentStart: segmentStart,
                segmentCount: segmentCount,
                navigationCellStart: navigationCellStart
            ))
        }
        guard Set(result.map(\.body)).count == result.count else { throw OrboSpineArtifactError.invalidRecord }
        return result
    }

    private static func validateBodyRanges(
        _ bodies: [MundaneBody: BodyEntry],
        segmentSection: DirectoryEntry,
        navigationSection: DirectoryEntry
    ) throws {
        guard segmentSection.recordSize == 40,
              navigationSection.recordSize == 16 else { throw OrboSpineArtifactError.invalidSectionDirectory }
        var expectedSegmentStart = 0
        var expectedNavigationCellStart = 0
        for body in MundaneBody.canonicalOrder {
            guard let entry = bodies[body],
                  entry.segmentStart == expectedSegmentStart,
                  entry.segmentCount > 0,
                  entry.segmentStart <= segmentSection.recordCount,
                  entry.segmentCount <= segmentSection.recordCount - entry.segmentStart,
                  entry.navigationCellStart == expectedNavigationCellStart,
                  entry.navigationCellStart <= navigationSection.recordCount,
                  720 <= navigationSection.recordCount - entry.navigationCellStart else {
                throw OrboSpineArtifactError.invalidSectionDirectory
            }
            expectedSegmentStart += entry.segmentCount
            expectedNavigationCellStart += 720
        }
        guard expectedSegmentStart == segmentSection.recordCount,
              expectedNavigationCellStart == navigationSection.recordCount else {
            throw OrboSpineArtifactError.invalidSectionDirectory
        }
    }

    private static func validateInventory(
        _ inventory: OrboSpineRuntimeInventory,
        sections: [OrboSpineArtifactFormat.Section: DirectoryEntry]
    ) throws {
        guard sections[.metadata]?.recordSize == 0,
              sections[.metadata]?.recordCount == 1,
              sections[.bodyDirectory]?.recordSize == 32,
              sections[.bodyDirectory]?.recordCount == MundaneBody.canonicalOrder.count,
              sections[.segments]?.recordSize == 40,
              sections[.navigationDirectory]?.recordSize == 16,
              sections[.navigationIndices]?.recordSize == 8,
              sections[.terra]?.recordSize == 24,
              sections[.stations]?.recordSize == 24,
              sections[.retrogradePassages]?.recordSize == 40,
              sections[.ring]?.recordSize == 32,
              sections[.eclipses]?.recordSize == 0,
              sections[.shells]?.recordSize == 24,
              inventory.stationCount == sections[.stations]?.recordCount,
              inventory.retrogradePassageCount == sections[.retrogradePassages]?.recordCount,
              inventory.ringOccurrenceCount == sections[.ring]?.recordCount,
              inventory.eclipseCount == sections[.eclipses]?.recordCount,
              inventory.shellIntervalCount == sections[.shells]?.recordCount,
              inventory.terraSampleCount == sections[.terra]?.recordCount else {
            throw OrboSpineArtifactError.invalidMetadata
        }
    }

    private static func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private static let epsilon = 1e-10
}

// MARK: - Encoding

internal enum OrboSpineArtifactEncoder {
    private struct SectionBytes {
        let id: OrboSpineArtifactFormat.Section
        let recordSize: UInt32
        let recordCount: UInt64
        let data: Data
    }

    static func encode(_ matter: OrboSpineArtifactMatter) throws -> Data {
        let tracts = matter.tracts.sorted { $0.body.rawValue < $1.body.rawValue }
        guard !matter.schematicIdentity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              matter.schematicVersion > 0,
              matter.candidateManifestSHA256.count == 64,
              matter.candidateManifestSHA256.allSatisfy({ $0.isHexDigit }),
              !matter.astronomicalAuthority.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !matter.astronomicalSourceVersion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              tracts.map(\.body) == MundaneBody.canonicalOrder,
              tracts.allSatisfy({ valid($0, on: matter.bone) }),
              matter.terra.count >= 2,
              matter.terra.allSatisfy({ $0.julianDay.value >= matter.bone.start.value && $0.julianDay.value <= matter.bone.end.value }),
              matter.stations.allSatisfy({ matter.bone.contains($0.julianDay) }),
              matter.retrogradePassages.allSatisfy({ $0.start.value >= matter.bone.start.value && $0.end.value <= matter.bone.end.value }),
              matter.ring.allSatisfy({ matter.bone.contains($0.julianDay) }),
              matter.eclipses.allSatisfy({ eclipse in
                  matter.bone.contains(eclipse.julianDay)
                      && (eclipse.greatestEclipseJulianDay == nil
                          || matter.bone.contains(eclipse.greatestEclipseJulianDay!))
              }),
              matter.shells.allSatisfy({ $0.start.value < matter.bone.end.value && $0.end.value > matter.bone.start.value }),
              matter.inventory.stationCount == matter.stations.count,
              matter.inventory.retrogradePassageCount == matter.retrogradePassages.count,
              matter.inventory.ringOccurrenceCount == matter.ring.count,
              matter.inventory.eclipseCount == matter.eclipses.count,
              matter.inventory.shellIntervalCount == matter.shells.count,
              matter.inventory.terraSampleCount == matter.terra.count else {
            throw OrboSpineArtifactError.invalidMatter
        }

        var bodyDirectory = BinaryWriter()
        var segments = BinaryWriter()
        var navigationDirectory = BinaryWriter()
        var navigationIndices = BinaryWriter()
        var globalSegmentStart: UInt64 = 0
        var globalNavigationCellStart: UInt64 = 0
        var globalNavigationIndexStart: UInt64 = 0

        for tract in tracts {
            bodyDirectory.u8(tract.body.rawValue)
            bodyDirectory.zeros(7)
            bodyDirectory.u64(globalSegmentStart)
            bodyDirectory.u64(UInt64(tract.segments.count))
            bodyDirectory.u64(globalNavigationCellStart)

            for segment in tract.segments {
                guard segment.start.value < segment.end.value,
                      segment.startPhysicalDegrees >= 0, segment.startPhysicalDegrees < 360,
                      segment.endPhysicalDegrees >= 0, segment.endPhysicalDegrees < 360 else {
                    throw OrboSpineArtifactError.invalidRecord
                }
                segments.double(segment.start.value)
                segments.double(segment.end.value)
                segments.u8(encodeMotion(segment.motion))
                segments.zeros(7)
                segments.double(segment.startPhysicalDegrees)
                segments.double(segment.endPhysicalDegrees)
            }

            for cell in tract.segmentIndexesByCell {
                guard cell.allSatisfy({ $0 >= 0 && $0 < tract.segments.count }) else {
                    throw OrboSpineArtifactError.invalidNavigation
                }
                navigationDirectory.u64(globalNavigationIndexStart)
                navigationDirectory.u32(UInt32(cell.count))
                navigationDirectory.u32(0)
                for index in cell { navigationIndices.u64(UInt64(index)) }
                globalNavigationIndexStart += UInt64(cell.count)
            }
            globalSegmentStart += UInt64(tract.segments.count)
            globalNavigationCellStart += 720
        }

        let orderedTerra = matter.terra.sorted {
            if $0.julianDay != $1.julianDay { return $0.julianDay.value < $1.julianDay.value }
            if $0.turnDegrees != $1.turnDegrees { return $0.turnDegrees < $1.turnDegrees }
            return $0.tiltDegrees < $1.tiltDegrees
        }
        var terra = BinaryWriter()
        for sample in orderedTerra {
            terra.double(sample.julianDay.value)
            terra.double(sample.turnDegrees)
            terra.double(sample.tiltDegrees)
        }

        let orderedStations = matter.stations.sorted {
            if $0.julianDay != $1.julianDay { return $0.julianDay.value < $1.julianDay.value }
            if $0.body != $1.body { return $0.body.rawValue < $1.body.rawValue }
            if $0.physicalDegrees != $1.physicalDegrees { return $0.physicalDegrees < $1.physicalDegrees }
            return encodeMotion($0.laneAfter) < encodeMotion($1.laneAfter)
        }
        var stations = BinaryWriter()
        for station in orderedStations {
            stations.u8(station.body.rawValue)
            stations.u8(encodeMotion(station.laneBefore))
            stations.u8(encodeMotion(station.laneAfter))
            stations.u8(0)
            stations.u32(0)
            stations.double(station.julianDay.value)
            stations.double(station.physicalDegrees)
        }

        let orderedPassages = matter.retrogradePassages.sorted {
            if $0.start != $1.start { return $0.start.value < $1.start.value }
            if $0.body != $1.body { return $0.body.rawValue < $1.body.rawValue }
            if $0.end != $1.end { return $0.end.value < $1.end.value }
            return encodeRetrogradeBoundary($0.startBoundary) < encodeRetrogradeBoundary($1.startBoundary)
        }
        var passages = BinaryWriter()
        for passage in orderedPassages {
            passages.u8(passage.body.rawValue)
            passages.u8(encodeRetrogradeBoundary(passage.startBoundary))
            passages.u8(encodeRetrogradeBoundary(passage.endBoundary))
            var flags: UInt8 = 0
            if passage.startStationPhysicalDegrees != nil { flags |= 0x01 }
            if passage.endStationPhysicalDegrees != nil { flags |= 0x02 }
            passages.u8(flags)
            passages.u32(0)
            passages.double(passage.start.value)
            passages.double(passage.end.value)
            passages.double(passage.startStationPhysicalDegrees ?? 0)
            passages.double(passage.endStationPhysicalDegrees ?? 0)
        }

        let orderedRing = matter.ring.sorted {
            if $0.julianDay != $1.julianDay { return $0.julianDay.value < $1.julianDay.value }
            if $0.bodyA != $1.bodyA { return $0.bodyA.rawValue < $1.bodyA.rawValue }
            if $0.bodyB != $1.bodyB { return $0.bodyB.rawValue < $1.bodyB.rawValue }
            if $0.mark != $1.mark { return $0.mark.rawValue < $1.mark.rawValue }
            if $0.bodyADirectionalDegree != $1.bodyADirectionalDegree { return $0.bodyADirectionalDegree.degrees < $1.bodyADirectionalDegree.degrees }
            return $0.bodyBDirectionalDegree.degrees < $1.bodyBDirectionalDegree.degrees
        }
        var ring = BinaryWriter()
        for occurrence in orderedRing {
            ring.u8(occurrence.bodyA.rawValue)
            ring.u8(occurrence.bodyB.rawValue)
            ring.u16(UInt16(occurrence.mark.rawValue))
            ring.u32(0)
            ring.double(occurrence.bodyADirectionalDegree.degrees)
            ring.double(occurrence.bodyBDirectionalDegree.degrees)
            ring.double(occurrence.julianDay.value)
        }

        let orderedEclipses = matter.eclipses.sorted {
            if $0.julianDay != $1.julianDay { return $0.julianDay.value < $1.julianDay.value }
            if $0.kind != $1.kind { return encodeEclipseKind($0.kind) < encodeEclipseKind($1.kind) }
            if $0.type != $1.type { return encodeEclipseType($0.type) < encodeEclipseType($1.type) }
            return $0.eclipseDegree < $1.eclipseDegree
        }
        var eclipses = BinaryWriter()
        for eclipse in orderedEclipses {
            eclipses.u8(encodeEclipseKind(eclipse.kind))
            eclipses.u8(encodeEclipseType(eclipse.type))
            var flags: UInt8 = 0
            if eclipse.greatestEclipseJulianDay != nil { flags |= 0x01 }
            if eclipse.magnitude != nil { flags |= 0x02 }
            if eclipse.secondaryMagnitude != nil { flags |= 0x04 }
            eclipses.u8(flags)
            eclipses.u8(0)
            eclipses.double(eclipse.eclipseDegree)
            eclipses.double(eclipse.julianDay.value)
            eclipses.double(eclipse.greatestEclipseJulianDay?.value ?? 0)
            eclipses.double(eclipse.magnitude ?? 0)
            eclipses.double(eclipse.secondaryMagnitude ?? 0)
            eclipses.stringBytes(eclipse.centrality ?? "")
        }

        let orderedShells = matter.shells.sorted {
            if $0.id.family != $1.id.family { return encodeShellFamily($0.id.family) < encodeShellFamily($1.id.family) }
            if $0.id.ordinal != $1.id.ordinal { return $0.id.ordinal < $1.id.ordinal }
            if $0.start != $1.start { return $0.start.value < $1.start.value }
            return $0.end.value < $1.end.value
        }
        var shells = BinaryWriter()
        for shell in orderedShells {
            shells.u8(encodeShellFamily(shell.id.family))
            shells.zeros(3)
            shells.u32(UInt32(shell.id.ordinal))
            shells.double(shell.start.value)
            shells.double(shell.end.value)
        }

        var metadata = BinaryWriter()
        metadata.string(matter.schematicIdentity)
        metadata.u16(matter.schematicVersion)
        metadata.u16(0)
        metadata.double(matter.bone.start.value)
        metadata.double(matter.bone.end.value)
        metadata.string(matter.candidateManifestSHA256.lowercased())
        metadata.string(matter.astronomicalAuthority)
        metadata.string(matter.astronomicalSourceVersion)
        metadata.u64(UInt64(matter.inventory.celestialSupportCount))
        metadata.u64(UInt64(matter.inventory.stationCount))
        metadata.u64(UInt64(matter.inventory.retrogradePassageCount))
        metadata.u64(UInt64(matter.inventory.ringOccurrenceCount))
        metadata.u64(UInt64(matter.inventory.eclipseCount))
        metadata.u64(UInt64(matter.inventory.shellIntervalCount))
        metadata.u64(UInt64(matter.inventory.terraSampleCount))

        let sectionBytes: [SectionBytes] = [
            .init(id: .metadata, recordSize: 0, recordCount: 1, data: metadata.data),
            .init(id: .bodyDirectory, recordSize: 32, recordCount: UInt64(tracts.count), data: bodyDirectory.data),
            .init(id: .segments, recordSize: 40, recordCount: globalSegmentStart, data: segments.data),
            .init(id: .navigationDirectory, recordSize: 16, recordCount: globalNavigationCellStart, data: navigationDirectory.data),
            .init(id: .navigationIndices, recordSize: 8, recordCount: globalNavigationIndexStart, data: navigationIndices.data),
            .init(id: .terra, recordSize: 24, recordCount: UInt64(orderedTerra.count), data: terra.data),
            .init(id: .stations, recordSize: 24, recordCount: UInt64(orderedStations.count), data: stations.data),
            .init(id: .retrogradePassages, recordSize: 40, recordCount: UInt64(orderedPassages.count), data: passages.data),
            .init(id: .ring, recordSize: 32, recordCount: UInt64(orderedRing.count), data: ring.data),
            .init(id: .eclipses, recordSize: 0, recordCount: UInt64(orderedEclipses.count), data: eclipses.data),
            .init(id: .shells, recordSize: 24, recordCount: UInt64(orderedShells.count), data: shells.data),
        ]

        let directoryOffset = OrboSpineArtifactFormat.headerSize
        let payloadOffset = directoryOffset + sectionBytes.count * OrboSpineArtifactFormat.directoryEntrySize
        var currentOffset = payloadOffset
        var directory = BinaryWriter()
        for section in sectionBytes {
            directory.u32(section.id.rawValue)
            directory.u32(section.recordSize)
            directory.u64(UInt64(currentOffset))
            directory.u64(UInt64(section.data.count))
            directory.u64(section.recordCount)
            currentOffset += section.data.count
        }

        var file = BinaryWriter()
        file.bytes(OrboSpineArtifactFormat.magic)
        file.u16(OrboSpineArtifactFormat.version)
        file.u8(OrboSpineArtifactFormat.littleEndianMarker)
        file.u8(0)
        file.u32(UInt32(sectionBytes.count))
        file.u64(UInt64(directoryOffset))
        file.u32(UInt32(OrboSpineArtifactFormat.directoryEntrySize))
        file.u32(UInt32(OrboSpineArtifactFormat.headerSize))
        file.data.append(directory.data)
        for section in sectionBytes { file.data.append(section.data) }
        return file.data
    }

    private static func valid(_ tract: OrboSpineArtifactTract, on bone: OrboSpineBoneSpan) -> Bool {
        guard tract.segmentIndexesByCell.count == 720,
              let first = tract.segments.first,
              let last = tract.segments.last,
              abs(first.start.value - bone.start.value) <= 1e-10,
              abs(last.end.value - bone.end.value) <= 1e-10 else { return false }
        for (index, segment) in tract.segments.enumerated() {
            guard segment.start.value < segment.end.value,
                  segment.start.value >= bone.start.value - 1e-10,
                  segment.end.value <= bone.end.value + 1e-10,
                  segment.startPhysicalDegrees.isFinite,
                  segment.endPhysicalDegrees.isFinite,
                  (0..<360).contains(segment.startPhysicalDegrees),
                  (0..<360).contains(segment.endPhysicalDegrees) else { return false }
            if index > 0 {
                let previous = tract.segments[index - 1]
                let rawDifference = abs(previous.endPhysicalDegrees - segment.startPhysicalDegrees)
                guard abs(previous.end.value - segment.start.value) <= 1e-10,
                      min(rawDifference, 360 - rawDifference) <= 1e-7 else { return false }
            }
        }
        var expected = Array(repeating: [Int](), count: 720)
        for (index, segment) in tract.segments.enumerated() {
            for cell in navigationCells(for: segment) { expected[cell].append(index) }
        }
        return tract.segmentIndexesByCell == expected
    }

    private static func navigationCells(for segment: OrboSpineArtifactSegment) -> [Int] {
        let laneOffset = segment.motion == .retrograde ? 360 : 0
        var result: [Int] = []
        var cell = Int(segment.startPhysicalDegrees.rounded(.down)) % 360
        let endCell = Int(segment.endPhysicalDegrees.rounded(.down)) % 360
        var safety = 0
        while true {
            result.append(laneOffset + cell)
            if cell == endCell { break }
            cell = segment.motion == .direct ? (cell + 1) % 360 : (cell + 359) % 360
            safety += 1
            if safety > 360 { return [] }
        }
        return result
    }
}

// MARK: - Stable enum grammar

private func encodeMotion(_ motion: Motion) -> UInt8 { motion == .direct ? 0 : 1 }
private func decodeMotion(_ raw: UInt8) -> Motion? {
    switch raw { case 0: return .direct; case 1: return .retrograde; default: return nil }
}
private func encodeRetrogradeBoundary(_ value: OrboSpineRetrogradeBoundary) -> UInt8 {
    switch value { case .station: return 0; case .spineStart: return 1; case .spineEnd: return 2 }
}
private func decodeRetrogradeBoundary(_ raw: UInt8) -> OrboSpineRetrogradeBoundary? {
    switch raw { case 0: return .station; case 1: return .spineStart; case 2: return .spineEnd; default: return nil }
}
private func encodeEclipseKind(_ value: OrboSpineEclipseKind) -> UInt8 { value == .solar ? 0 : 1 }
private func decodeEclipseKind(_ raw: UInt8) -> OrboSpineEclipseKind? {
    switch raw { case 0: return .solar; case 1: return .lunar; default: return nil }
}
private func encodeEclipseType(_ value: OrboSpineEclipseType) -> UInt8 {
    switch value { case .total: return 0; case .annular: return 1; case .hybrid: return 2; case .partial: return 3; case .penumbral: return 4 }
}
private func decodeEclipseType(_ raw: UInt8) -> OrboSpineEclipseType? {
    switch raw { case 0: return .total; case 1: return .annular; case 2: return .hybrid; case 3: return .partial; case 4: return .penumbral; default: return nil }
}
private func encodeShellFamily(_ value: OrboSpineShellFamily) -> UInt8 {
    switch value { case .frame: return 0; case .revolt: return 1; case .wave: return 2; case .zeitgeist: return 3 }
}
private func decodeShellFamily(_ raw: UInt8) -> OrboSpineShellFamily? {
    switch raw { case 0: return .frame; case 1: return .revolt; case 2: return .wave; case 3: return .zeitgeist; default: return nil }
}

private func directionalDistance(from start: Double, to end: Double, motion: Motion) -> Double {
    switch motion { case .direct: return normalized(end - start); case .retrograde: return normalized(start - end) }
}
private func move(from start: Double, by distance: Double, motion: Motion) -> Double {
    switch motion { case .direct: return normalized(start + distance); case .retrograde: return normalized(start - distance) }
}
private func normalized(_ value: Double) -> Double {
    var result = value.truncatingRemainder(dividingBy: 360)
    if result < 0 { result += 360 }
    return result == 360 ? 0 : result
}

// MARK: - Binary primitives

private struct BinaryWriter {
    var data = Data()

    mutating func bytes(_ values: [UInt8]) { data.append(contentsOf: values) }
    mutating func zeros(_ count: Int) { data.append(contentsOf: repeatElement(UInt8(0), count: count)) }
    mutating func u8(_ value: UInt8) { data.append(value) }
    mutating func u16(_ value: UInt16) { appendInteger(value.littleEndian) }
    mutating func u32(_ value: UInt32) { appendInteger(value.littleEndian) }
    mutating func u64(_ value: UInt64) { appendInteger(value.littleEndian) }
    mutating func double(_ value: Double) { u64(value.bitPattern) }
    mutating func string(_ value: String) {
        let bytes = Array(value.utf8)
        u32(UInt32(bytes.count))
        self.bytes(bytes)
    }
    mutating func stringBytes(_ value: String) {
        let bytes = Array(value.utf8)
        u32(UInt32(bytes.count))
        self.bytes(bytes)
    }
    private mutating func appendInteger<T>(_ value: T) {
        var value = value
        withUnsafeBytes(of: &value) { data.append(contentsOf: $0) }
    }
}

private struct BinaryReader {
    let data: Data
    var offset: Int
    let limit: Int

    var isAtEnd: Bool { offset == limit }

    mutating func u8() throws -> UInt8 {
        let values = try bytes(count: 1)
        return values[0]
    }
    mutating func u16() throws -> UInt16 { try integer(UInt16.self) }
    mutating func u32() throws -> UInt32 { try integer(UInt32.self) }
    mutating func u64() throws -> UInt64 { try integer(UInt64.self) }
    mutating func double() throws -> Double { Double(bitPattern: try u64()) }
    mutating func string() throws -> String {
        let length = Int(try u32())
        let value = try bytes(count: length)
        guard let string = String(bytes: value, encoding: .utf8) else { throw OrboSpineArtifactError.invalidRecord }
        return string
    }
    mutating func bytes(count: Int) throws -> [UInt8] {
        guard count >= 0, offset >= 0, offset <= limit, count <= limit - offset else {
            throw OrboSpineArtifactError.malformedArtifact
        }
        let range = offset..<(offset + count)
        offset += count
        return Array(data[range])
    }
    private mutating func integer<T: FixedWidthInteger>(_ type: T.Type) throws -> T {
        let count = MemoryLayout<T>.size
        let values = try bytes(count: count)
        var value: T = 0
        for (index, byte) in values.enumerated() { value |= T(byte) << T(index * 8) }
        return value
    }
}
