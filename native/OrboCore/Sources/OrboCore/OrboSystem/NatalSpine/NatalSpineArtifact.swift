import Foundation
#if canImport(CryptoKit)
import CryptoKit
#else
import Crypto
#endif

/// Stable, sectioned binary representation of one finished Natal Spine.
/// Hephaestus writes this once; ordinary runtime code only maps and reads it.
public enum NatalSpineArtifactFormat {
    public static let version: UInt16 = 2
    static let magic = Array("NATLSP01".utf8)
    static let littleEndianMarker: UInt8 = 1
    static let headerSize = 32
    static let directoryEntrySize = 32

    enum Section: UInt32, CaseIterable {
        case metadata = 1
        case celestialSupports = 2
        case stations = 3
        case boundaryAnchors = 4
        case themis = 5
        case oceanus = 6
        case rhea = 7
        case locateBodyDirectory = 8
        case locateSegments = 9
        case locateNavigationDirectory = 10
        case locateNavigationIndices = 11
    }
}

public struct NatalSpineArtifactReceipt: Hashable, Codable, Sendable {
    public let sha256: String
    public let byteCount: Int
    public let formatVersion: UInt16
    public let subjectID: String
    public let parentSpineIdentity: String

    public init(
        sha256: String,
        byteCount: Int,
        formatVersion: UInt16,
        subjectID: String,
        parentSpineIdentity: String
    ) {
        self.sha256 = sha256
        self.byteCount = byteCount
        self.formatVersion = formatVersion
        self.subjectID = subjectID
        self.parentSpineIdentity = parentSpineIdentity
    }

    /// The receipt is deliberately external to the artifact it authenticates.
    public func write(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(self).write(to: url, options: .atomic)
    }

    public static func read(from url: URL) throws -> NatalSpineArtifactReceipt {
        try JSONDecoder().decode(Self.self, from: Data(contentsOf: url))
    }
}

public enum NatalSpineArtifactError: Error, Equatable, Sendable {
    case malformedArtifact
    case unsupportedVersion(UInt16)
    case wrongByteOrder
    case invalidSectionDirectory
    case invalidMetadata
    case invalidRecord
    case invalidMatter(String)
    case artifactIdentityMismatch(expected: String, actual: String)
    case parentIdentityMismatch(expected: String, actual: String)
    case outsideBone
    case bodyUnavailable(MundaneBody)
    case themisCoverageMismatch(MundaneBody)
}

public struct NatalSpineRuntimeThemisRecord: Hashable, Sendable {
    public let sourceRow: Int
    public let body: MundaneBody
    public let house: House
    public let start: JulianDay
    public let end: JulianDay
}

public struct NatalSpineRuntimeOceanusRecord: Hashable, Sendable {
    public let sourceRow: Int
    public let mundaneBody: MundaneBody
    public let natalGene: AstroDNAGene
    public let natalSource: RingFineState
    public let relation: RingMark
    public let targetArcsecond: Int
    public let occurrence: OrboSpineCelestialCoordinate
}

public enum NatalSpineRuntimeRheaSource: Hashable, Sendable {
    case houseCrossing(
        body: MundaneBody,
        fromHouse: House,
        toHouse: House,
        previousThemisSourceRow: Int,
        nextThemisSourceRow: Int,
        occurrence: JulianDay
    )
    case ringRealization(
        body: MundaneBody,
        oceanusSourceRow: Int,
        occurrence: JulianDay
    )
    case materMoment(
        body: MundaneBody,
        occurrence: JulianDay
    )

    public var body: MundaneBody {
        switch self {
        case let .houseCrossing(body, _, _, _, _, _),
             let .ringRealization(body, _, _),
             let .materMoment(body, _):
            return body
        }
    }

    public var occurrence: JulianDay {
        switch self {
        case let .houseCrossing(_, _, _, _, _, occurrence),
             let .ringRealization(_, _, occurrence),
             let .materMoment(_, occurrence):
            return occurrence
        }
    }
}

public struct NatalSpineRuntimeRheaRecord: Hashable, Sendable {
    public let sourceRow: Int
    public let source: NatalSpineRuntimeRheaSource
    public let longitude: CelestialLongitude
    public let conditions: [NatalSpineMaterCondition]
}

public struct NatalSpineRuntimeAddress: Hashable, Sendable {
    public let coordinate: OrboSpineCelestialCoordinate
    public let themisSourceRow: Int
    public let oceanusSourceRows: [Int]
    public let rheaSourceRows: [Int]
}

/// A mounted Natal Spine. Its source bytes remain memory-mapped for the lifetime
/// of this value; decoding admits only compact, already-forged records.
public struct NatalSpineRuntime: @unchecked Sendable {
    public let subjectID: HermesSubjectID
    public let packageID: HermesPackageID
    public let bounds: NatalSpineBounds
    public let parentProvenance: OrboSpineRuntimeProvenance
    public let artifactSHA256: String
    public let themis: [NatalSpineRuntimeThemisRecord]
    public let oceanus: [NatalSpineRuntimeOceanusRecord]
    public let rhea: [NatalSpineRuntimeRheaRecord]

    private let artifact: NatalSpineMountedArtifact

    public static func mount(
        from url: URL,
        expectedSHA256: String,
        expectedParentSpineIdentity: String
    ) throws -> NatalSpineRuntime {
        let artifact = try NatalSpineMountedArtifact(url: url)
        let expected = expectedSHA256.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard artifact.sha256 == expected else {
            throw NatalSpineArtifactError.artifactIdentityMismatch(
                expected: expected,
                actual: artifact.sha256
            )
        }
        guard artifact.parentProvenance.spineIdentity == expectedParentSpineIdentity else {
            throw NatalSpineArtifactError.parentIdentityMismatch(
                expected: expectedParentSpineIdentity,
                actual: artifact.parentProvenance.spineIdentity
            )
        }
        return try artifact.runtime()
    }

    fileprivate init(artifact: NatalSpineMountedArtifact) {
        subjectID = artifact.subjectID
        packageID = artifact.packageID
        bounds = artifact.bounds
        parentProvenance = artifact.parentProvenance
        artifactSHA256 = artifact.sha256
        themis = artifact.themis
        oceanus = artifact.oceanus
        rhea = artifact.rhea
        self.artifact = artifact
    }

    public func address(
        of body: MundaneBody,
        at julianDay: JulianDay
    ) throws -> NatalSpineRuntimeAddress {
        guard bounds.bone.contains(julianDay) else {
            throw NatalSpineArtifactError.outsideBone
        }
        let coordinate = try artifact.mappedCoordinate(of: body, at: julianDay)
        return try address(for: coordinate)
    }

    public func addresses(
        of body: MundaneBody,
        at directionalDegree: OrboSpineDirectionalDegree
    ) throws -> [NatalSpineRuntimeAddress] {
        try artifact.mappedOccurrences(of: body, at: directionalDegree)
            .filter { bounds.bone.contains($0.julianDay) }
            .map { try address(for: $0) }
    }

    private func address(
        for coordinate: OrboSpineCelestialCoordinate
    ) throws -> NatalSpineRuntimeAddress {
        let epsilon = 1e-9
        let covering = themis.filter {
            $0.body == coordinate.body
                && coordinate.julianDay.value >= $0.start.value - epsilon
                && coordinate.julianDay.value < $0.end.value - epsilon
        }
        guard covering.count == 1, let house = covering.first else {
            throw NatalSpineArtifactError.themisCoverageMismatch(coordinate.body)
        }
        let oceanusRows = oceanus.compactMap { record -> Int? in
            let event = record.occurrence
            guard event.body == coordinate.body,
                  abs(event.julianDay.value - coordinate.julianDay.value) <= epsilon,
                  event.directionalDegree.motion == coordinate.directionalDegree.motion,
                  abs(event.directionalDegree.physicalDegrees
                      - coordinate.directionalDegree.physicalDegrees) <= 1e-7 else {
                return nil
            }
            return record.sourceRow
        }.sorted()
        let rheaRows = rhea.compactMap { record in
            record.source.body == coordinate.body
                && abs(record.source.occurrence.value - coordinate.julianDay.value) <= epsilon
                ? record.sourceRow : nil
        }.sorted()
        return NatalSpineRuntimeAddress(
            coordinate: coordinate,
            themisSourceRow: house.sourceRow,
            oceanusSourceRows: oceanusRows,
            rheaSourceRows: rheaRows
        )
    }
}

public extension Hephaestus {
    /// Permanently transcribes the independently approved, sealed candidate.
    /// The write is atomic and is immediately remounted before a receipt is issued.
    static func forgeNatalSpineArtifact(
        _ sealed: SealedNatalSpine,
        to url: URL
    ) throws -> NatalSpineArtifactReceipt {
        let bytes = try NatalSpineArtifactEncoder.encode(sealed)
        try bytes.write(to: url, options: .atomic)
        let mounted = try NatalSpineMountedArtifact(url: url)
        guard try mounted.finishedLocateTracts() == sealed.candidate.artifactTracts else {
            throw NatalSpineArtifactError.invalidMatter("finished Locate navigation")
        }
        _ = try mounted.runtime()
        return NatalSpineArtifactReceipt(
            sha256: mounted.sha256,
            byteCount: bytes.count,
            formatVersion: NatalSpineArtifactFormat.version,
            subjectID: mounted.subjectID.rawValue,
            parentSpineIdentity: mounted.parentProvenance.spineIdentity
        )
    }
}

final class NatalSpineMountedArtifact: OrboSpineMappedNavigationReading, @unchecked Sendable {
    fileprivate struct DirectoryEntry {
        let recordSize: Int
        let offset: Int
        let byteLength: Int
        let recordCount: Int
    }

    private struct LocateBodyEntry {
        let body: MundaneBody
        let segmentStart: Int
        let segmentCount: Int
        let navigationCellStart: Int
    }

    let data: Data
    let sha256: String
    let subjectID: HermesSubjectID
    let packageID: HermesPackageID
    let bounds: NatalSpineBounds
    let parentProvenance: OrboSpineRuntimeProvenance
    let themis: [NatalSpineRuntimeThemisRecord]
    let oceanus: [NatalSpineRuntimeOceanusRecord]
    let rhea: [NatalSpineRuntimeRheaRecord]
    private let sections: [NatalSpineArtifactFormat.Section: DirectoryEntry]
    private let bodies: [MundaneBody: LocateBodyEntry]

    convenience init(url: URL) throws {
        try self.init(data: Data(contentsOf: url, options: .mappedIfSafe))
    }

    init(data: Data) throws {
        guard data.count >= NatalSpineArtifactFormat.headerSize else {
            throw NatalSpineArtifactError.malformedArtifact
        }
        var reader = NatalBinaryReader(data: data, offset: 0, limit: data.count)
        guard try reader.bytes(count: 8) == NatalSpineArtifactFormat.magic else {
            throw NatalSpineArtifactError.malformedArtifact
        }
        let version = try reader.u16()
        guard version == NatalSpineArtifactFormat.version else {
            throw NatalSpineArtifactError.unsupportedVersion(version)
        }
        guard try reader.u8() == NatalSpineArtifactFormat.littleEndianMarker else {
            throw NatalSpineArtifactError.wrongByteOrder
        }
        _ = try reader.u8()
        let sectionCount = Int(try reader.u32())
        guard let directoryOffset = Int(exactly: try reader.u64()) else {
            throw NatalSpineArtifactError.invalidSectionDirectory
        }
        let entrySize = Int(try reader.u32())
        let headerSize = Int(try reader.u32())
        guard sectionCount == NatalSpineArtifactFormat.Section.allCases.count,
              directoryOffset == headerSize,
              headerSize == NatalSpineArtifactFormat.headerSize,
              entrySize == NatalSpineArtifactFormat.directoryEntrySize,
              directoryOffset + sectionCount * entrySize <= data.count else {
            throw NatalSpineArtifactError.invalidSectionDirectory
        }

        var directoryReader = NatalBinaryReader(
            data: data,
            offset: directoryOffset,
            limit: directoryOffset + sectionCount * entrySize
        )
        var sections: [NatalSpineArtifactFormat.Section: DirectoryEntry] = [:]
        for _ in 0..<sectionCount {
            guard let section = NatalSpineArtifactFormat.Section(rawValue: try directoryReader.u32()),
                  sections[section] == nil else {
                throw NatalSpineArtifactError.invalidSectionDirectory
            }
            let recordSize = Int(try directoryReader.u32())
            guard let offset = Int(exactly: try directoryReader.u64()),
                  let byteLength = Int(exactly: try directoryReader.u64()),
                  let recordCount = Int(exactly: try directoryReader.u64()),
                  offset >= directoryOffset + sectionCount * entrySize,
                  byteLength >= 0,
                  offset <= data.count,
                  byteLength <= data.count - offset else {
                throw NatalSpineArtifactError.invalidSectionDirectory
            }
            guard recordSize == 0
                    || (recordCount == 0 ? byteLength == 0
                        : byteLength % recordCount == 0 && byteLength / recordCount == recordSize) else {
                throw NatalSpineArtifactError.invalidSectionDirectory
            }
            sections[section] = DirectoryEntry(
                recordSize: recordSize,
                offset: offset,
                byteLength: byteLength,
                recordCount: recordCount
            )
        }
        guard sections.count == sectionCount else {
            throw NatalSpineArtifactError.invalidSectionDirectory
        }
        let ordered = sections.values.sorted {
            if $0.offset != $1.offset { return $0.offset < $1.offset }
            return $0.byteLength < $1.byteLength
        }
        var previousEnd = directoryOffset + sectionCount * entrySize
        for section in ordered {
            guard section.offset == previousEnd else {
                throw NatalSpineArtifactError.invalidSectionDirectory
            }
            previousEnd += section.byteLength
        }
        guard previousEnd == data.count,
              sections[.celestialSupports]?.recordSize == 24,
              sections[.stations]?.recordSize == 24,
              sections[.boundaryAnchors]?.recordSize == 24,
              sections[.themis]?.recordSize == 24,
              sections[.oceanus]?.recordSize == 32,
              sections[.rhea]?.recordSize == 40,
              sections[.locateBodyDirectory]?.recordSize == 32,
              sections[.locateBodyDirectory]?.recordCount == MundaneBody.canonicalOrder.count,
              sections[.locateSegments]?.recordSize == 40,
              sections[.locateNavigationDirectory]?.recordSize == 16,
              sections[.locateNavigationDirectory]?.recordCount == MundaneBody.canonicalOrder.count * 720,
              sections[.locateNavigationIndices]?.recordSize == 8,
              let metadataSection = sections[.metadata] else {
            throw NatalSpineArtifactError.invalidSectionDirectory
        }

        var metadata = NatalBinaryReader(
            data: data,
            offset: metadataSection.offset,
            limit: metadataSection.offset + metadataSection.byteLength
        )
        guard let subjectID = HermesSubjectID(rawValue: try metadata.string()),
              let packageUUID = UUID(uuidString: try metadata.string()),
              let start = AbsoluteInstant(unixSecondsSince1970: try metadata.double()),
              let natal = AbsoluteInstant(unixSecondsSince1970: try metadata.double()),
              let end = AbsoluteInstant(unixSecondsSince1970: try metadata.double()),
              let bounds = NatalSpineBounds(subjectID: subjectID, start: start, natal: natal, end: end) else {
            throw NatalSpineArtifactError.invalidMetadata
        }
        let candidateDigest = try metadata.string()
        let artifactDigest = try metadata.string()
        let authority = try metadata.string()
        let sourceVersion = try metadata.string()
        guard metadata.isAtEnd,
              let provenance = OrboSpineRuntimeProvenance(
                candidateManifestSHA256: candidateDigest,
                artifactSHA256: artifactDigest.isEmpty ? nil : artifactDigest,
                astronomicalAuthority: authority,
                astronomicalSourceVersion: sourceVersion
              ) else {
            throw NatalSpineArtifactError.invalidMetadata
        }

        let themis = try Self.readThemis(data, section: sections[.themis]!)
        let oceanus = try Self.readOceanus(data, section: sections[.oceanus]!)
        let rhea = try Self.readRhea(data, section: sections[.rhea]!)
        let bodies = try Self.readLocateBodies(
            data, bodySection: sections[.locateBodyDirectory]!,
            segmentSection: sections[.locateSegments]!,
            navigationSection: sections[.locateNavigationDirectory]!
        )
        guard sections[.celestialSupports]!.recordCount >= MundaneBody.canonicalOrder.count * 2,
              sections[.boundaryAnchors]!.recordCount == MundaneBody.canonicalOrder.count * 2,
              themis.enumerated().allSatisfy({ $0.offset == $0.element.sourceRow }),
              oceanus.enumerated().allSatisfy({ $0.offset == $0.element.sourceRow }),
              rhea.enumerated().allSatisfy({ $0.offset == $0.element.sourceRow }) else {
            throw NatalSpineArtifactError.invalidRecord
        }

        self.data = data
        sha256 = Self.sha256Hex(data)
        self.subjectID = subjectID
        packageID = HermesPackageID(packageUUID)
        self.bounds = bounds
        parentProvenance = provenance
        self.themis = themis
        self.oceanus = oceanus
        self.rhea = rhea
        self.sections = sections
        self.bodies = Dictionary(uniqueKeysWithValues: bodies.map { ($0.body, $0) })
    }

    func runtime() throws -> NatalSpineRuntime { NatalSpineRuntime(artifact: self) }

    var navigationBone: OrboSpineBoneSpan { bounds.bone }
    func navigationSegmentCount(of body: MundaneBody) -> Int? { bodies[body]?.segmentCount }

    func navigationSegment(of body: MundaneBody, localIndex: Int) throws -> OrboSpineArtifactSegment {
        guard let entry = bodies[body], (0..<entry.segmentCount).contains(localIndex) else {
            throw NatalSpineArtifactError.bodyUnavailable(body)
        }
        let section = sections[.locateSegments]!
        let offset = section.offset + (entry.segmentStart + localIndex) * 40
        var reader = NatalBinaryReader(data: data, offset: offset, limit: offset + 40)
        guard let start = JulianDay(try reader.double()),
              let end = JulianDay(try reader.double()), start.value < end.value,
              let motion = decodeNatalMotion(try reader.u8()) else {
            throw NatalSpineArtifactError.invalidRecord
        }
        try reader.skip(7)
        let startDegrees = try reader.double()
        let endDegrees = try reader.double()
        guard (0..<360).contains(startDegrees), (0..<360).contains(endDegrees),
              start.value >= bounds.bone.start.value - 1e-10,
              end.value <= bounds.bone.end.value + 1e-10 else {
            throw NatalSpineArtifactError.invalidRecord
        }
        return OrboSpineArtifactSegment(
            start: start,
            end: end,
            startPhysicalDegrees: startDegrees,
            endPhysicalDegrees: endDegrees,
            motion: motion
        )
    }

    func navigationIndices(of body: MundaneBody, cell: Int) throws -> [Int] {
        guard (0..<720).contains(cell), let entry = bodies[body] else {
            throw NatalSpineArtifactError.invalidRecord
        }
        let nav = sections[.locateNavigationDirectory]!
        let indices = sections[.locateNavigationIndices]!
        let offset = nav.offset + (entry.navigationCellStart + cell) * 16
        var reader = NatalBinaryReader(data: data, offset: offset, limit: offset + 16)
        guard let start = Int(exactly: try reader.u64()) else {
            throw NatalSpineArtifactError.invalidRecord
        }
        let count = Int(try reader.u32())
        guard try reader.u32() == 0,
              start <= indices.recordCount,
              count <= indices.recordCount - start else {
            throw NatalSpineArtifactError.invalidRecord
        }
        return try (0..<count).map { item in
            let itemOffset = indices.offset + (start + item) * 8
            var value = NatalBinaryReader(data: data, offset: itemOffset, limit: itemOffset + 8)
            guard let index = Int(exactly: try value.u64()), index < entry.segmentCount else {
                throw NatalSpineArtifactError.invalidRecord
            }
            return index
        }
    }

    func finishedLocateTracts() throws -> [OrboSpineArtifactTract] {
        try Self.readLocateTracts(
            data,
            bodySection: sections[.locateBodyDirectory]!,
            segmentSection: sections[.locateSegments]!,
            navigationSection: sections[.locateNavigationDirectory]!,
            indexSection: sections[.locateNavigationIndices]!
        )
    }

    private static func readSupports(_ data: Data, section: DirectoryEntry) throws -> [OrboSpineCelestialCoordinate] {
        var reader = NatalBinaryReader(data: data, offset: section.offset, limit: section.offset + section.byteLength)
        return try (0..<section.recordCount).map { _ in
            guard let body = MundaneBody(rawValue: try reader.u8()) else { throw NatalSpineArtifactError.invalidRecord }
            try reader.skip(7)
            guard let degree = OrboSpineDirectionalDegree(try reader.double()),
                  let day = JulianDay(try reader.double()) else { throw NatalSpineArtifactError.invalidRecord }
            return OrboSpineCelestialCoordinate(body: body, directionalDegree: degree, julianDay: day)
        }
    }

    private static func readStations(_ data: Data, section: DirectoryEntry) throws -> [OrboSpineStation] {
        var reader = NatalBinaryReader(data: data, offset: section.offset, limit: section.offset + section.byteLength)
        return try (0..<section.recordCount).map { _ in
            guard let body = MundaneBody(rawValue: try reader.u8()),
                  let before = decodeNatalMotion(try reader.u8()),
                  let after = decodeNatalMotion(try reader.u8()) else { throw NatalSpineArtifactError.invalidRecord }
            try reader.skip(5)
            guard let day = JulianDay(try reader.double()),
                  let station = OrboSpineStation(
                    body: body,
                    physicalDegrees: try reader.double(),
                    julianDay: day,
                    laneBefore: before,
                    laneAfter: after
                  ) else { throw NatalSpineArtifactError.invalidRecord }
            return station
        }
    }

    private static func readAnchors(_ data: Data, section: DirectoryEntry) throws -> [OrboSpineBoundaryAnchor] {
        var reader = NatalBinaryReader(data: data, offset: section.offset, limit: section.offset + section.byteLength)
        return try (0..<section.recordCount).map { _ in
            guard let body = MundaneBody(rawValue: try reader.u8()),
                  let boundary = decodeNatalBoundary(try reader.u8()),
                  let motion = decodeNatalMotion(try reader.u8()) else { throw NatalSpineArtifactError.invalidRecord }
            try reader.skip(5)
            guard let day = JulianDay(try reader.double()),
                  let anchor = OrboSpineBoundaryAnchor(
                    body: body,
                    boundary: boundary,
                    julianDay: day,
                    physicalDegrees: try reader.double(),
                    motion: motion
                  ) else { throw NatalSpineArtifactError.invalidRecord }
            return anchor
        }
    }

    private static func readThemis(_ data: Data, section: DirectoryEntry) throws -> [NatalSpineRuntimeThemisRecord] {
        var reader = NatalBinaryReader(data: data, offset: section.offset, limit: section.offset + section.byteLength)
        return try (0..<section.recordCount).map { _ in
            let row = Int(try reader.u32())
            guard let body = MundaneBody(rawValue: try reader.u8()),
                  let house = House(rawValue: Int(try reader.u8())) else { throw NatalSpineArtifactError.invalidRecord }
            try reader.skip(2)
            guard let start = JulianDay(try reader.double()),
                  let end = JulianDay(try reader.double()),
                  start.value < end.value else { throw NatalSpineArtifactError.invalidRecord }
            return NatalSpineRuntimeThemisRecord(sourceRow: row, body: body, house: house, start: start, end: end)
        }
    }

    private static func readOceanus(_ data: Data, section: DirectoryEntry) throws -> [NatalSpineRuntimeOceanusRecord] {
        var reader = NatalBinaryReader(data: data, offset: section.offset, limit: section.offset + section.byteLength)
        return try (0..<section.recordCount).map { _ in
            let row = Int(try reader.u32())
            let bodyRaw = try reader.u8()
            let geneOrdinal = Int(try reader.u8())
            let relationRaw = Int(try reader.u16())
            let natalSourceRaw = Int(try reader.u32())
            guard let body = MundaneBody(rawValue: bodyRaw),
                  let gene = AstroDNAGene.canonicalOrder.first(where: { $0.ordinal == geneOrdinal }),
                  let relation = RingMark(rawValue: relationRaw),
                  let natalSource = RingFineState(natalSourceRaw) else { throw NatalSpineArtifactError.invalidRecord }
            let target = Int(try reader.u32())
            guard let degree = OrboSpineDirectionalDegree(try reader.double()),
                  let day = JulianDay(try reader.double()) else { throw NatalSpineArtifactError.invalidRecord }
            return NatalSpineRuntimeOceanusRecord(
                sourceRow: row,
                mundaneBody: body,
                natalGene: gene,
                natalSource: natalSource,
                relation: relation,
                targetArcsecond: target,
                occurrence: OrboSpineCelestialCoordinate(body: body, directionalDegree: degree, julianDay: day)
            )
        }
    }

    private static func readRhea(_ data: Data, section: DirectoryEntry) throws -> [NatalSpineRuntimeRheaRecord] {
        var reader = NatalBinaryReader(data: data, offset: section.offset, limit: section.offset + section.byteLength)
        return try (0..<section.recordCount).map { _ in
            let row = Int(try reader.u32())
            let kind = try reader.u8()
            guard let body = MundaneBody(rawValue: try reader.u8()) else { throw NatalSpineArtifactError.invalidRecord }
            let fromRaw = Int(try reader.u8())
            let toRaw = Int(try reader.u8())
            let referenceA = Int(try reader.u32())
            let referenceB = Int(try reader.u32())
            let conditionBits = try reader.u32()
            try reader.skip(4)
            guard let occurrence = JulianDay(try reader.double()),
                  let longitude = CelestialLongitude(try reader.double()) else { throw NatalSpineArtifactError.invalidRecord }
            let source: NatalSpineRuntimeRheaSource
            switch kind {
            case 0:
                guard let from = House(rawValue: fromRaw),
                      let to = House(rawValue: toRaw),
                      from != to else { throw NatalSpineArtifactError.invalidRecord }
                source = .houseCrossing(
                    body: body,
                    fromHouse: from,
                    toHouse: to,
                    previousThemisSourceRow: referenceA,
                    nextThemisSourceRow: referenceB,
                    occurrence: occurrence
                )
            case 1:
                source = .ringRealization(
                    body: body,
                    oceanusSourceRow: referenceA,
                    occurrence: occurrence
                )
            case 2:
                guard fromRaw == 0, toRaw == 0, referenceA == 0, referenceB == 0 else {
                    throw NatalSpineArtifactError.invalidRecord
                }
                source = .materMoment(body: body, occurrence: occurrence)
            default:
                throw NatalSpineArtifactError.invalidRecord
            }
            return NatalSpineRuntimeRheaRecord(
                sourceRow: row,
                source: source,
                longitude: longitude,
                conditions: decodeNatalConditions(conditionBits)
            )
        }
    }

    private static func readLocateBodies(
        _ data: Data,
        bodySection: DirectoryEntry,
        segmentSection: DirectoryEntry,
        navigationSection: DirectoryEntry
    ) throws -> [LocateBodyEntry] {
        var bodyReader = NatalBinaryReader(
            data: data,
            offset: bodySection.offset,
            limit: bodySection.offset + bodySection.byteLength
        )
        let bodies: [LocateBodyEntry] = try (0..<bodySection.recordCount).map { _ in
            guard let body = MundaneBody(rawValue: try bodyReader.u8()) else {
                throw NatalSpineArtifactError.invalidRecord
            }
            try bodyReader.skip(7)
            guard let segmentStart = Int(exactly: try bodyReader.u64()),
                  let segmentCount = Int(exactly: try bodyReader.u64()),
                  let navigationCellStart = Int(exactly: try bodyReader.u64()),
                  segmentStart >= 0,
                  segmentCount > 0,
                  navigationCellStart >= 0,
                  segmentStart <= segmentSection.recordCount,
                  segmentCount <= segmentSection.recordCount - segmentStart,
                  navigationCellStart <= navigationSection.recordCount,
                  720 <= navigationSection.recordCount - navigationCellStart else {
                throw NatalSpineArtifactError.invalidRecord
            }
            return LocateBodyEntry(
                body: body,
                segmentStart: segmentStart,
                segmentCount: segmentCount,
                navigationCellStart: navigationCellStart
            )
        }
        guard bodies.map(\.body) == MundaneBody.canonicalOrder else {
            throw NatalSpineArtifactError.invalidRecord
        }

        var segmentEnd = 0
        var cellEnd = 0
        for entry in bodies {
            guard entry.segmentStart == segmentEnd,
                  entry.navigationCellStart == cellEnd else {
                throw NatalSpineArtifactError.invalidRecord
            }
            segmentEnd += entry.segmentCount
            cellEnd += 720
        }
        guard segmentEnd == segmentSection.recordCount,
              cellEnd == navigationSection.recordCount else {
            throw NatalSpineArtifactError.invalidRecord
        }
        return bodies
    }

    private static func readLocateTracts(
        _ data: Data,
        bodySection: DirectoryEntry,
        segmentSection: DirectoryEntry,
        navigationSection: DirectoryEntry,
        indexSection: DirectoryEntry
    ) throws -> [OrboSpineArtifactTract] {
        let bodies = try readLocateBodies(
            data,
            bodySection: bodySection,
            segmentSection: segmentSection,
            navigationSection: navigationSection
        )

        return try bodies.map { bodyEntry in
            let segments = try (0..<bodyEntry.segmentCount).map { localIndex in
                let globalIndex = bodyEntry.segmentStart + localIndex
                let offset = segmentSection.offset + globalIndex * segmentSection.recordSize
                var reader = NatalBinaryReader(
                    data: data,
                    offset: offset,
                    limit: offset + segmentSection.recordSize
                )
                guard let start = JulianDay(try reader.double()),
                      let end = JulianDay(try reader.double()),
                      start.value < end.value,
                      let motion = decodeNatalMotion(try reader.u8()) else {
                    throw NatalSpineArtifactError.invalidRecord
                }
                try reader.skip(7)
                let startDegrees = try reader.double()
                let endDegrees = try reader.double()
                guard reader.isAtEnd,
                      startDegrees.isFinite,
                      endDegrees.isFinite,
                      (0..<360).contains(startDegrees),
                      (0..<360).contains(endDegrees) else {
                    throw NatalSpineArtifactError.invalidRecord
                }
                return OrboSpineArtifactSegment(
                    start: start,
                    end: end,
                    startPhysicalDegrees: startDegrees,
                    endPhysicalDegrees: endDegrees,
                    motion: motion
                )
            }

            let cells: [[Int]] = try (0..<720).map { cell in
                let navRecordIndex = bodyEntry.navigationCellStart + cell
                let navOffset = navigationSection.offset + navRecordIndex * navigationSection.recordSize
                var navigationReader = NatalBinaryReader(
                    data: data,
                    offset: navOffset,
                    limit: navOffset + navigationSection.recordSize
                )
                guard let indexStart = Int(exactly: try navigationReader.u64()) else {
                    throw NatalSpineArtifactError.invalidRecord
                }
                let count = Int(try navigationReader.u32())
                guard try navigationReader.u32() == 0,
                      navigationReader.isAtEnd,
                      indexStart >= 0,
                      count >= 0,
                      indexStart <= indexSection.recordCount,
                      count <= indexSection.recordCount - indexStart else {
                    throw NatalSpineArtifactError.invalidRecord
                }
                return try (0..<count).map { item in
                    let indexOffset = indexSection.offset + (indexStart + item) * indexSection.recordSize
                    var indexReader = NatalBinaryReader(
                        data: data,
                        offset: indexOffset,
                        limit: indexOffset + indexSection.recordSize
                    )
                    guard let localIndex = Int(exactly: try indexReader.u64()),
                          indexReader.isAtEnd,
                          localIndex >= 0,
                          localIndex < bodyEntry.segmentCount else {
                        throw NatalSpineArtifactError.invalidRecord
                    }
                    return localIndex
                }
            }
            return OrboSpineArtifactTract(
                body: bodyEntry.body,
                segments: segments,
                segmentIndexesByCell: cells
            )
        }
    }

    private static func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}

private enum NatalSpineArtifactEncoder {
    private struct SectionBytes {
        let id: NatalSpineArtifactFormat.Section
        let recordSize: UInt32
        let recordCount: UInt64
        let data: Data
    }

    static func encode(_ sealed: SealedNatalSpine) throws -> Data {
        let candidate = sealed.candidate
        guard candidate.subjectID == sealed.subjectID,
              candidate.bounds == sealed.bounds,
              candidate.themis.count == sealed.seal.themisCount,
              candidate.oceanus.count == sealed.seal.oceanusCount,
              candidate.rhea.count == sealed.seal.rheaCount else {
            throw NatalSpineArtifactError.invalidMatter("seal continuity")
        }

        var metadata = NatalBinaryWriter()
        metadata.string(sealed.subjectID.rawValue)
        metadata.string(sealed.packageID.rawValue.uuidString.lowercased())
        metadata.double(sealed.bounds.start.unixSecondsSince1970)
        metadata.double(sealed.bounds.natal.unixSecondsSince1970)
        metadata.double(sealed.bounds.end.unixSecondsSince1970)
        metadata.string(sealed.seal.parentProvenance.candidateManifestSHA256)
        metadata.string(sealed.seal.parentProvenance.artifactSHA256 ?? "")
        metadata.string(sealed.seal.parentProvenance.astronomicalAuthority)
        metadata.string(sealed.seal.parentProvenance.astronomicalSourceVersion)

        let supportsSource = candidate.substrate.supports.sorted(by: celestialOrder)
        var supports = NatalBinaryWriter()
        for coordinate in supportsSource {
            supports.u8(coordinate.body.rawValue)
            supports.zeros(7)
            supports.double(coordinate.directionalDegree.degrees)
            supports.double(coordinate.julianDay.value)
        }

        let stationsSource = candidate.substrate.stations.sorted {
            if $0.julianDay != $1.julianDay { return $0.julianDay.value < $1.julianDay.value }
            return $0.body.rawValue < $1.body.rawValue
        }
        var stations = NatalBinaryWriter()
        for station in stationsSource {
            stations.u8(station.body.rawValue)
            stations.u8(encodeNatalMotion(station.laneBefore))
            stations.u8(encodeNatalMotion(station.laneAfter))
            stations.zeros(5)
            stations.double(station.julianDay.value)
            stations.double(station.physicalDegrees)
        }

        let anchorsSource = candidate.substrate.boundaryAnchors.sorted {
            if $0.body != $1.body { return $0.body.rawValue < $1.body.rawValue }
            return encodeNatalBoundary($0.boundary) < encodeNatalBoundary($1.boundary)
        }
        var anchors = NatalBinaryWriter()
        for anchor in anchorsSource {
            anchors.u8(anchor.body.rawValue)
            anchors.u8(encodeNatalBoundary(anchor.boundary))
            anchors.u8(encodeNatalMotion(anchor.motion))
            anchors.zeros(5)
            anchors.double(anchor.julianDay.value)
            anchors.double(anchor.physicalDegrees)
        }

        var themis = NatalBinaryWriter()
        for (index, forged) in candidate.themis.enumerated() {
            guard forged.sourceRow == index else {
                throw NatalSpineArtifactError.invalidMatter("Themis source rows")
            }
            themis.u32(UInt32(index))
            themis.u8(forged.span.body.rawValue)
            themis.u8(UInt8(forged.span.house.rawValue))
            themis.zeros(2)
            themis.double(forged.span.start.value)
            themis.double(forged.span.end.value)
        }

        var oceanus = NatalBinaryWriter()
        for (index, forged) in candidate.oceanus.enumerated() {
            let value = forged.realization
            guard forged.sourceRow == index else {
                throw NatalSpineArtifactError.invalidMatter("Oceanus source rows")
            }
            oceanus.u32(UInt32(index))
            oceanus.u8(value.mundaneBody.rawValue)
            oceanus.u8(UInt8(value.natalGene.ordinal))
            oceanus.u16(UInt16(value.relation.rawValue))
            oceanus.u32(UInt32(value.natalSource.rawValue))
            oceanus.u32(UInt32(value.targetArcsecond))
            oceanus.double(value.occurrence.directionalDegree.degrees)
            oceanus.double(value.occurrence.julianDay.value)
        }

        var rhea = NatalBinaryWriter()
        for (index, forged) in candidate.rhea.enumerated() {
            guard forged.sourceRow == index else {
                throw NatalSpineArtifactError.invalidMatter("Rhea source rows")
            }
            let qualification = forged.qualification
            rhea.u32(UInt32(index))
            rhea.u8(2)
            rhea.u8(qualification.source.body.rawValue)
            rhea.zeros(2)
            rhea.u32(0)
            rhea.u32(0)
            rhea.u32(encodeNatalConditions(qualification.temper))
            rhea.u32(0)
            rhea.double(qualification.source.julianDay.value)
            rhea.double(qualification.temper.longitude.degrees)
        }

        let navigationStart = ProcessInfo.processInfo.systemUptime
        let tracts = candidate.artifactTracts
        guard tracts.map(\.body) == MundaneBody.canonicalOrder,
              tracts.allSatisfy({ OrboSpineArtifactEncoder.valid($0, on: candidate.bounds.bone) }) else {
            throw NatalSpineArtifactError.invalidMatter("Locate body order")
        }
        var locateBodyDirectory = NatalBinaryWriter()
        var locateSegments = NatalBinaryWriter()
        var locateNavigationDirectory = NatalBinaryWriter()
        var locateNavigationIndices = NatalBinaryWriter()
        var globalSegmentStart: UInt64 = 0
        var globalNavigationCellStart: UInt64 = 0
        var globalNavigationIndexStart: UInt64 = 0
        for tract in tracts {
            guard tract.segmentIndexesByCell.count == 720 else {
                throw NatalSpineArtifactError.invalidMatter("Locate navigation cells")
            }
            locateBodyDirectory.u8(tract.body.rawValue)
            locateBodyDirectory.zeros(7)
            locateBodyDirectory.u64(globalSegmentStart)
            locateBodyDirectory.u64(UInt64(tract.segments.count))
            locateBodyDirectory.u64(globalNavigationCellStart)

            for segment in tract.segments {
                guard segment.start.value < segment.end.value,
                      segment.startPhysicalDegrees.isFinite,
                      segment.endPhysicalDegrees.isFinite,
                      (0..<360).contains(segment.startPhysicalDegrees),
                      (0..<360).contains(segment.endPhysicalDegrees) else {
                    throw NatalSpineArtifactError.invalidMatter("Locate segment")
                }
                locateSegments.double(segment.start.value)
                locateSegments.double(segment.end.value)
                locateSegments.u8(encodeNatalMotion(segment.motion))
                locateSegments.zeros(7)
                locateSegments.double(segment.startPhysicalDegrees)
                locateSegments.double(segment.endPhysicalDegrees)
            }

            for cell in tract.segmentIndexesByCell {
                guard cell.allSatisfy({ $0 >= 0 && $0 < tract.segments.count }) else {
                    throw NatalSpineArtifactError.invalidMatter("Locate navigation index")
                }
                locateNavigationDirectory.u64(globalNavigationIndexStart)
                locateNavigationDirectory.u32(UInt32(cell.count))
                locateNavigationDirectory.u32(0)
                for index in cell { locateNavigationIndices.u64(UInt64(index)) }
                globalNavigationIndexStart += UInt64(cell.count)
            }
            globalSegmentStart += UInt64(tract.segments.count)
            globalNavigationCellStart += 720
        }
        let navigationElapsed = ProcessInfo.processInfo.systemUptime - navigationStart
        print(
            "ORBO_NATAL_ARTIFACT navigation-encode elapsed=\(String(format: "%.3f", navigationElapsed))s "
                + "tracts=\(tracts.count) segments=\(globalSegmentStart) indices=\(globalNavigationIndexStart)"
        )

        let sections: [SectionBytes] = [
            .init(id: .metadata, recordSize: 0, recordCount: 1, data: metadata.data),
            .init(id: .celestialSupports, recordSize: 24, recordCount: UInt64(supportsSource.count), data: supports.data),
            .init(id: .stations, recordSize: 24, recordCount: UInt64(stationsSource.count), data: stations.data),
            .init(id: .boundaryAnchors, recordSize: 24, recordCount: UInt64(anchorsSource.count), data: anchors.data),
            .init(id: .themis, recordSize: 24, recordCount: UInt64(candidate.themis.count), data: themis.data),
            .init(id: .oceanus, recordSize: 32, recordCount: UInt64(candidate.oceanus.count), data: oceanus.data),
            .init(id: .rhea, recordSize: 40, recordCount: UInt64(candidate.rhea.count), data: rhea.data),
            .init(id: .locateBodyDirectory, recordSize: 32, recordCount: UInt64(tracts.count), data: locateBodyDirectory.data),
            .init(id: .locateSegments, recordSize: 40, recordCount: globalSegmentStart, data: locateSegments.data),
            .init(id: .locateNavigationDirectory, recordSize: 16, recordCount: globalNavigationCellStart, data: locateNavigationDirectory.data),
            .init(id: .locateNavigationIndices, recordSize: 8, recordCount: globalNavigationIndexStart, data: locateNavigationIndices.data),
        ]
        return assemble(sections)
    }

    private static func assemble(_ sections: [SectionBytes]) -> Data {
        let directoryOffset = NatalSpineArtifactFormat.headerSize
        var currentOffset = directoryOffset + sections.count * NatalSpineArtifactFormat.directoryEntrySize
        var directory = NatalBinaryWriter()
        for section in sections {
            directory.u32(section.id.rawValue)
            directory.u32(section.recordSize)
            directory.u64(UInt64(currentOffset))
            directory.u64(UInt64(section.data.count))
            directory.u64(section.recordCount)
            currentOffset += section.data.count
        }
        var file = NatalBinaryWriter()
        file.bytes(NatalSpineArtifactFormat.magic)
        file.u16(NatalSpineArtifactFormat.version)
        file.u8(NatalSpineArtifactFormat.littleEndianMarker)
        file.u8(0)
        file.u32(UInt32(sections.count))
        file.u64(UInt64(directoryOffset))
        file.u32(UInt32(NatalSpineArtifactFormat.directoryEntrySize))
        file.u32(UInt32(NatalSpineArtifactFormat.headerSize))
        file.data.append(directory.data)
        for section in sections { file.data.append(section.data) }
        return file.data
    }

    private static func celestialOrder(
        _ lhs: OrboSpineCelestialCoordinate,
        _ rhs: OrboSpineCelestialCoordinate
    ) -> Bool {
        if lhs.body != rhs.body { return lhs.body.rawValue < rhs.body.rawValue }
        if lhs.julianDay != rhs.julianDay { return lhs.julianDay.value < rhs.julianDay.value }
        return lhs.directionalDegree.degrees < rhs.directionalDegree.degrees
    }
}

private func encodeNatalMotion(_ motion: Motion) -> UInt8 { motion == .direct ? 0 : 1 }
private func decodeNatalMotion(_ raw: UInt8) -> Motion? {
    switch raw { case 0: return .direct; case 1: return .retrograde; default: return nil }
}
private func encodeNatalBoundary(_ boundary: OrboSpineBoundaryAnchorKind) -> UInt8 {
    boundary == .start ? 0 : 1
}
private func decodeNatalBoundary(_ raw: UInt8) -> OrboSpineBoundaryAnchorKind? {
    switch raw { case 0: return .start; case 1: return .endExclusive; default: return nil }
}

private let natalConditionOrder: [NatalSpineMaterCondition] = [
    .sectDay, .sectNight, .traditionalDomicile, .modernDomicile,
    .traditionalDetriment, .modernDetriment, .exaltation,
    .atExaltationDegree, .triplicity, .bound, .face, .fall,
    .peregrine, .mutualReception,
]

private func encodeNatalConditions(_ temper: Mater.QualifiedTemper) -> UInt32 {
    natalConditionOrder.enumerated().reduce(UInt32(0)) { bits, item in
        item.element.matches(temper) ? bits | (UInt32(1) << UInt32(item.offset)) : bits
    }
}

private func decodeNatalConditions(_ bits: UInt32) -> [NatalSpineMaterCondition] {
    natalConditionOrder.enumerated().compactMap {
        bits & (UInt32(1) << UInt32($0.offset)) == 0 ? nil : $0.element
    }
}

private struct NatalBinaryWriter {
    var data = Data()
    mutating func bytes(_ values: [UInt8]) { data.append(contentsOf: values) }
    mutating func zeros(_ count: Int) { data.append(contentsOf: repeatElement(UInt8(0), count: count)) }
    mutating func u8(_ value: UInt8) { data.append(value) }
    mutating func u16(_ value: UInt16) { appendInteger(value.littleEndian) }
    mutating func u32(_ value: UInt32) { appendInteger(value.littleEndian) }
    mutating func u64(_ value: UInt64) { appendInteger(value.littleEndian) }
    mutating func double(_ value: Double) { u64(value.bitPattern) }
    mutating func string(_ value: String) {
        let values = Array(value.utf8)
        u32(UInt32(values.count))
        bytes(values)
    }
    private mutating func appendInteger<T>(_ value: T) {
        var value = value
        withUnsafeBytes(of: &value) { data.append(contentsOf: $0) }
    }
}

private struct NatalBinaryReader {
    let data: Data
    var offset: Int
    let limit: Int
    var isAtEnd: Bool { offset == limit }

    mutating func u8() throws -> UInt8 { try bytes(count: 1)[0] }
    mutating func u16() throws -> UInt16 { try integer(UInt16.self) }
    mutating func u32() throws -> UInt32 { try integer(UInt32.self) }
    mutating func u64() throws -> UInt64 { try integer(UInt64.self) }
    mutating func double() throws -> Double { Double(bitPattern: try u64()) }
    mutating func string() throws -> String {
        let count = Int(try u32())
        guard let result = String(bytes: try bytes(count: count), encoding: .utf8) else {
            throw NatalSpineArtifactError.invalidRecord
        }
        return result
    }
    mutating func skip(_ count: Int) throws { _ = try bytes(count: count) }
    mutating func bytes(count: Int) throws -> [UInt8] {
        guard count >= 0, offset >= 0, offset <= limit, count <= limit - offset else {
            throw NatalSpineArtifactError.malformedArtifact
        }
        let range = offset..<(offset + count)
        offset += count
        return Array(data[range])
    }
    private mutating func integer<T: FixedWidthInteger>(_ type: T.Type) throws -> T {
        let values = try bytes(count: MemoryLayout<T>.size)
        var result: T = 0
        for (index, byte) in values.enumerated() { result |= T(byte) << T(index * 8) }
        return result
    }
}
