import Foundation

public struct MundaneTimespineArtifact: Sendable {
    public let data: Data

    public init(storageImage: MundaneTimespineStorageImage) throws {
        self.data = try storageImage.encodedArtifact()
    }

    public init(data: Data) throws {
        _ = try Self.readHeaderAndDirectory(data)
        self.data = data
    }

    public var storageVersion: UInt16 {
        (try? Self.readHeaderAndDirectory(data).version) ?? 0
    }

    public var storageIdentifier: String {
        guard let decoded = try? Self.readHeaderAndDirectory(data) else { return "" }
        return decoded.version == MundaneTimespineStorageFormat.legacyVersion ? "ORBOTS01" : "ORBOTS02"
    }

    public func storageImage() throws -> MundaneTimespineStorageImage {
        let decoded = try Self.readHeaderAndDirectory(data)
        let metadataSection = try Self.uniqueSection(.metadata, body: nil, in: decoded.sections)
        var metadata = try MundaneTimespineBinaryReader(
            data: data,
            range: metadataSection.offset..<(metadataSection.offset + metadataSection.length)
        )
        let spanName = try metadata.string()
        let source = try metadata.string()
        let sourceVersion = try metadata.string()
        guard metadata.isAtEnd else { throw MundaneTimespineStorageError.malformedArtifact }

        var bodies: [MundaneTimespineStoredBody] = []
        for section in decoded.sections where section.kind == .body {
            guard let body = section.body else { throw MundaneTimespineStorageError.malformedArtifact }
            bodies.append(try Self.decodeBody(body, section: section, data: data))
        }
        guard !bodies.isEmpty else { throw MundaneTimespineStorageError.sectionMissing("body chronology") }

        let boundaryStates: [MundaneTimespineStoredBoundaryState]
        if decoded.version == MundaneTimespineStorageFormat.version {
            let boundarySection = try Self.uniqueSection(.boundaries, body: nil, in: decoded.sections)
            boundaryStates = try Self.decodeBoundaries(section: boundarySection, data: data)
        } else {
            boundaryStates = []
        }

        let relationshipSection = try Self.uniqueSection(.relationships, body: nil, in: decoded.sections)
        let relationships = try Self.decodeRelationships(
            section: relationshipSection,
            data: data,
            supportedStart: decoded.start
        )
        let eclipseSection = try Self.uniqueSection(.eclipses, body: nil, in: decoded.sections)
        let eclipses = try Self.decodeEclipses(
            section: eclipseSection,
            data: data,
            supportedStart: decoded.start
        )

        guard let image = MundaneTimespineStorageImage(
            spanName: spanName,
            astronomicalSource: source,
            astronomicalSourceVersion: sourceVersion,
            supportedStart: decoded.start,
            supportedEnd: decoded.end,
            bodies: bodies,
            boundaryStates: boundaryStates,
            relationships: relationships,
            eclipses: eclipses
        ) else { throw MundaneTimespineStorageError.malformedArtifact }
        return image
    }

    public func runtimeImage() throws -> MundaneTimespineRuntimeImage {
        guard let runtime = try storageImage().runtimeImage() else {
            throw MundaneTimespineStorageError.malformedArtifact
        }
        return runtime
    }

    private struct DecodedHeader {
        let version: UInt16
        let start: JulianDay
        let end: JulianDay
        let sections: [MundaneTimespineStorageSection]
    }

    private static func readHeaderAndDirectory(_ data: Data) throws -> DecodedHeader {
        var reader = MundaneTimespineBinaryReader(data: data)
        let magic = try reader.bytes(MundaneTimespineStorageFormat.magic.count)
        let version = try reader.u16()
        let isCurrent = magic == MundaneTimespineStorageFormat.magic
            && version == MundaneTimespineStorageFormat.version
        let isLegacy = magic == MundaneTimespineStorageFormat.legacyMagic
            && version == MundaneTimespineStorageFormat.legacyVersion
        guard isCurrent || isLegacy else {
            if magic == MundaneTimespineStorageFormat.magic || magic == MundaneTimespineStorageFormat.legacyMagic {
                throw MundaneTimespineStorageError.unsupportedVersion(version)
            }
            throw MundaneTimespineStorageError.malformedArtifact
        }
        let flags = try reader.u16()
        guard flags & 1 == 1 else { throw MundaneTimespineStorageError.celestialTimeLawMissing }
        guard let start = JulianDay(try reader.f64()),
              let end = JulianDay(try reader.f64()),
              start.value < end.value else { throw MundaneTimespineStorageError.malformedArtifact }
        let sectionCount = Int(try reader.u16())
        _ = try reader.u16()
        var sections: [MundaneTimespineStorageSection] = []
        sections.reserveCapacity(sectionCount)
        var identities = Set<String>()
        for _ in 0..<sectionCount {
            let kindRaw = try reader.byte()
            guard let kind = MundaneTimespineStorageSectionKind(rawValue: kindRaw) else {
                throw MundaneTimespineStorageError.malformedArtifact
            }
            if isLegacy && kind == .boundaries { throw MundaneTimespineStorageError.malformedArtifact }
            let bodyRaw = try reader.byte()
            let body: MundaneBody?
            if bodyRaw == 0xff {
                body = nil
            } else if let parsed = MundaneBody(rawValue: bodyRaw) {
                body = parsed
            } else {
                throw MundaneTimespineStorageError.invalidBody(bodyRaw)
            }
            _ = try reader.u16()
            let offset = try reader.int(try reader.u64())
            let length = try reader.int(try reader.u64())
            let count = Int(try reader.u32())
            guard offset >= 32 + 24 * sectionCount,
                  length >= 0,
                  offset <= data.count,
                  length <= data.count - offset else {
                throw MundaneTimespineStorageError.malformedArtifact
            }
            if kind == .body, body == nil { throw MundaneTimespineStorageError.malformedArtifact }
            if kind != .body, body != nil { throw MundaneTimespineStorageError.malformedArtifact }
            let identity = "\(kind.rawValue):\(bodyRaw)"
            guard identities.insert(identity).inserted else { throw MundaneTimespineStorageError.duplicateSection }
            sections.append(MundaneTimespineStorageSection(
                kind: kind,
                body: body,
                offset: offset,
                length: length,
                recordCount: count
            ))
        }
        let ordered = sections.sorted { $0.offset < $1.offset }
        for i in 1..<ordered.count {
            guard ordered[i - 1].offset + ordered[i - 1].length <= ordered[i].offset else {
                throw MundaneTimespineStorageError.malformedArtifact
            }
        }
        return DecodedHeader(version: version, start: start, end: end, sections: sections)
    }

    private static func uniqueSection(
        _ kind: MundaneTimespineStorageSectionKind,
        body: MundaneBody?,
        in sections: [MundaneTimespineStorageSection]
    ) throws -> MundaneTimespineStorageSection {
        let matches = sections.filter { $0.kind == kind && $0.body == body }
        guard matches.count == 1 else {
            if matches.isEmpty { throw MundaneTimespineStorageError.sectionMissing("section \(kind.rawValue)") }
            throw MundaneTimespineStorageError.duplicateSection
        }
        return matches[0]
    }

    private static func decodeBoundaries(
        section: MundaneTimespineStorageSection,
        data: Data
    ) throws -> [MundaneTimespineStoredBoundaryState] {
        var reader = try MundaneTimespineBinaryReader(
            data: data,
            range: section.offset..<(section.offset + section.length)
        )
        var result: [MundaneTimespineStoredBoundaryState] = []
        result.reserveCapacity(section.recordCount)
        var seen = Set<MundaneBody>()
        for _ in 0..<section.recordCount {
            let rawBody = try reader.byte()
            guard let body = MundaneBody(rawValue: rawBody), seen.insert(body).inserted else {
                if MundaneBody(rawValue: rawBody) == nil { throw MundaneTimespineStorageError.invalidBody(rawBody) }
                throw MundaneTimespineStorageError.malformedArtifact
            }
            let startMicro = try reader.varUInt()
            let startMotion = try decodeMotion(try reader.byte())
            let endMicro = try reader.varUInt()
            let endMotion = try decodeMotion(try reader.byte())
            guard startMicro < MundaneTimespineStorageFormat.circleMicrodegrees,
                  endMicro < MundaneTimespineStorageFormat.circleMicrodegrees,
                  let state = MundaneTimespineStoredBoundaryState(
                    body: body,
                    startCelestialMicrodegrees: UInt32(startMicro),
                    startMotion: startMotion,
                    endCelestialMicrodegrees: UInt32(endMicro),
                    endMotion: endMotion
                  ) else { throw MundaneTimespineStorageError.malformedArtifact }
            result.append(state)
        }
        guard reader.isAtEnd else { throw MundaneTimespineStorageError.malformedArtifact }
        return result
    }

    private static func decodeBody(
        _ body: MundaneBody,
        section: MundaneTimespineStorageSection,
        data: Data
    ) throws -> MundaneTimespineStoredBody {
        var reader = try MundaneTimespineBinaryReader(data: data, range: section.offset..<(section.offset + section.length))
        let ticksPerDegree = try reader.int(try reader.varUInt())
        let markerCount = try reader.int(try reader.varUInt())
        var markerBodies: [MundaneBody] = []
        markerBodies.reserveCapacity(markerCount)
        for _ in 0..<markerCount {
            let raw = try reader.byte()
            guard let marker = MundaneBody(rawValue: raw) else { throw MundaneTimespineStorageError.invalidBody(raw) }
            markerBodies.append(marker)
        }
        let occurrenceCount = try reader.int(try reader.varUInt())
        let stationCount = try reader.int(try reader.varUInt())
        let passageCount = try reader.int(try reader.varUInt())
        guard occurrenceCount == section.recordCount else { throw MundaneTimespineStorageError.malformedArtifact }

        var occurrences: [MundaneTimespineStoredOccurrence] = []
        occurrences.reserveCapacity(occurrenceCount)
        var civicOffset: Int64 = 0
        for _ in 0..<occurrenceCount {
            let tick = try reader.int(try reader.varUInt())
            let delta = try reader.varUInt()
            guard delta <= UInt64(Int64.max - civicOffset) else { throw MundaneTimespineStorageError.integerOverflow }
            civicOffset += Int64(delta)
            let directionRaw = try reader.byte()
            let direction: MundaneCelestialSequenceDirection
            switch directionRaw {
            case 0: direction = .increasing
            case 1: direction = .decreasing
            default: throw MundaneTimespineStorageError.malformedArtifact
            }
            var markers: [UInt16] = []
            markers.reserveCapacity(markerCount)
            for _ in 0..<markerCount {
                let raw = try reader.varUInt()
                guard raw < 360 else { throw MundaneTimespineStorageError.malformedArtifact }
                markers.append(UInt16(raw))
            }
            occurrences.append(MundaneTimespineStoredOccurrence(
                celestialTick: tick,
                civicOffsetSeconds: civicOffset,
                sequenceDirection: direction,
                markerWholeDegrees: markers
            ))
        }

        var stations: [MundaneTimespineStoredStation] = []
        for _ in 0..<stationCount {
            let micro = try reader.varUInt()
            let civic = try reader.varUInt()
            guard micro < MundaneTimespineStorageFormat.circleMicrodegrees,
                  civic <= UInt64(Int64.max) else { throw MundaneTimespineStorageError.integerOverflow }
            stations.append(MundaneTimespineStoredStation(
                celestialMicrodegrees: UInt32(micro),
                civicOffsetSeconds: Int64(civic),
                motionAfter: try decodeMotion(try reader.byte())
            ))
        }

        var passages: [MundaneTimespineStoredRetrogradePassage] = []
        for _ in 0..<passageCount {
            let startMicro = try reader.varUInt()
            let endMicro = try reader.varUInt()
            let startOffset = try reader.varUInt()
            let endOffset = try reader.varUInt()
            guard startMicro < MundaneTimespineStorageFormat.circleMicrodegrees,
                  endMicro < MundaneTimespineStorageFormat.circleMicrodegrees,
                  startOffset <= UInt64(Int64.max), endOffset <= UInt64(Int64.max) else {
                throw MundaneTimespineStorageError.integerOverflow
            }
            passages.append(MundaneTimespineStoredRetrogradePassage(
                startCelestialMicrodegrees: UInt32(startMicro),
                endCelestialMicrodegrees: UInt32(endMicro),
                startCivicOffsetSeconds: Int64(startOffset),
                endCivicOffsetSeconds: Int64(endOffset)
            ))
        }
        guard reader.isAtEnd,
              let result = MundaneTimespineStoredBody(
                body: body,
                ticksPerDegree: ticksPerDegree,
                markerBodies: markerBodies,
                occurrences: occurrences,
                stations: stations,
                retrogradePassages: passages
              ) else { throw MundaneTimespineStorageError.malformedArtifact }
        return result
    }

    private static func decodeRelationships(
        section: MundaneTimespineStorageSection,
        data: Data,
        supportedStart: JulianDay
    ) throws -> [MundaneTimespineRelationshipEvent] {
        var reader = try MundaneTimespineBinaryReader(data: data, range: section.offset..<(section.offset + section.length))
        var result: [MundaneTimespineRelationshipEvent] = []
        result.reserveCapacity(section.recordCount)
        var civicOffset: Int64 = 0
        for _ in 0..<section.recordCount {
            let pair = try reader.byte()
            let aRaw = pair >> 4
            let bRaw = pair & 0x0f
            guard let bodyA = MundaneBody(rawValue: aRaw) else { throw MundaneTimespineStorageError.invalidBody(aRaw) }
            guard let bodyB = MundaneBody(rawValue: bRaw) else { throw MundaneTimespineStorageError.invalidBody(bRaw) }
            let markRaw = try reader.byte()
            guard let mark = RingMark(rawValue: Int(markRaw)) else { throw MundaneTimespineStorageError.invalidRingMark(markRaw) }
            let orientationRaw = try reader.byte()
            let orientation = try decodeOrientation(orientationRaw)
            try validateRelationshipOrientation(mark: mark, orientation: orientation)
            let aMicro = try reader.varUInt()
            let delta = try reader.varUInt()
            guard aMicro < MundaneTimespineStorageFormat.circleMicrodegrees,
                  delta <= UInt64(Int64.max - civicOffset) else { throw MundaneTimespineStorageError.integerOverflow }
            civicOffset += Int64(delta)
            let aDegree = Double(aMicro) / Double(MundaneTimespineStorageFormat.microdegreesPerDegree)
            let bDegree = relationshipOtherDegree(aDegree, mark: mark, orientation: orientation)
            let jd = JulianDay(supportedStart.value + Double(civicOffset) / 86_400)!
            guard let event = MundaneTimespineRelationshipEvent(
                bodyA: bodyA,
                bodyB: bodyB,
                mark: mark,
                orientation: orientation,
                bodyACelestialTimeDegrees: aDegree,
                bodyBCelestialTimeDegrees: bDegree,
                julianDay: jd,
                exactAspectResidualArcSeconds: 0
            ) else { throw MundaneTimespineStorageError.malformedArtifact }
            result.append(event)
        }
        guard reader.isAtEnd else { throw MundaneTimespineStorageError.malformedArtifact }
        return result
    }

    private static func decodeEclipses(
        section: MundaneTimespineStorageSection,
        data: Data,
        supportedStart: JulianDay
    ) throws -> [MundaneTimespineEclipseEvent] {
        var reader = try MundaneTimespineBinaryReader(data: data, range: section.offset..<(section.offset + section.length))
        var result: [MundaneTimespineEclipseEvent] = []
        result.reserveCapacity(section.recordCount)
        var civicOffset: Int64 = 0
        for _ in 0..<section.recordCount {
            let micro = try reader.varUInt()
            guard micro < MundaneTimespineStorageFormat.circleMicrodegrees else { throw MundaneTimespineStorageError.malformedArtifact }
            let kindRaw = try reader.byte()
            let kind: MundaneTimespineEclipseKind
            switch kindRaw {
            case 0: kind = .solar
            case 1: kind = .lunar
            default: throw MundaneTimespineStorageError.invalidEclipseKind(kindRaw)
            }
            let type = try decodeEclipseType(try reader.byte())
            let centrality = try decodeCentrality(try reader.byte())
            let options = try reader.byte()
            guard options & ~UInt8(7) == 0 else { throw MundaneTimespineStorageError.malformedArtifact }
            let delta = try reader.varUInt()
            guard delta <= UInt64(Int64.max - civicOffset) else { throw MundaneTimespineStorageError.integerOverflow }
            civicOffset += Int64(delta)
            let jd = JulianDay(supportedStart.value + Double(civicOffset) / 86_400)!
            let greatest: JulianDay?
            if options & 1 != 0 {
                greatest = JulianDay(jd.value + Double(try reader.varInt()) / 86_400)!
            } else {
                greatest = nil
            }
            let magnitude = options & 2 != 0 ? try reader.f64() : nil
            let secondary = options & 4 != 0 ? try reader.f64() : nil
            guard let event = MundaneTimespineEclipseEvent(
                kind: kind,
                type: type,
                eclipseDegree: Double(micro) / Double(MundaneTimespineStorageFormat.microdegreesPerDegree),
                julianDay: jd,
                greatestEclipseJulianDay: greatest,
                magnitude: magnitude,
                secondaryMagnitude: secondary,
                centrality: centrality
            ) else { throw MundaneTimespineStorageError.malformedArtifact }
            result.append(event)
        }
        guard reader.isAtEnd else { throw MundaneTimespineStorageError.malformedArtifact }
        return result
    }

    private static func decodeMotion(_ raw: UInt8) throws -> Motion {
        switch raw {
        case 0: return .direct
        case 1: return .retrograde
        default: throw MundaneTimespineStorageError.malformedArtifact
        }
    }

    private static func decodeOrientation(_ raw: UInt8) throws -> MundaneTimespineRelationshipOrientation {
        switch raw {
        case 0: return .sameDegree
        case 1: return .oppositeDegree
        case 2: return .bodyAAhead
        case 3: return .bodyBAhead
        default: throw MundaneTimespineStorageError.invalidOrientation(raw)
        }
    }

    private static func validateRelationshipOrientation(
        mark: RingMark,
        orientation: MundaneTimespineRelationshipOrientation
    ) throws {
        switch mark {
        case .conjunction:
            guard orientation == .sameDegree else { throw MundaneTimespineStorageError.malformedArtifact }
        case .opposition:
            guard orientation == .oppositeDegree else { throw MundaneTimespineStorageError.malformedArtifact }
        default:
            guard orientation == .bodyAAhead || orientation == .bodyBAhead else {
                throw MundaneTimespineStorageError.malformedArtifact
            }
        }
    }

    private static func relationshipOtherDegree(
        _ bodyADegree: Double,
        mark: RingMark,
        orientation: MundaneTimespineRelationshipOrientation
    ) -> Double {
        let raw: Double
        switch orientation {
        case .sameDegree: raw = bodyADegree
        case .oppositeDegree: raw = bodyADegree + 180
        case .bodyAAhead: raw = bodyADegree - Double(mark.rawValue)
        case .bodyBAhead: raw = bodyADegree + Double(mark.rawValue)
        }
        var normalized = raw.truncatingRemainder(dividingBy: 360)
        if normalized < 0 { normalized += 360 }
        return normalized
    }

    private static func decodeEclipseType(_ raw: UInt8) throws -> MundaneTimespineEclipseType {
        switch raw {
        case 0: return .total
        case 1: return .annular
        case 2: return .hybrid
        case 3: return .partial
        case 4: return .penumbral
        default: throw MundaneTimespineStorageError.invalidEclipseType(raw)
        }
    }

    private static func decodeCentrality(_ raw: UInt8) throws -> String? {
        switch raw {
        case 0: return nil
        case 1: return "central"
        case 2: return "noncentral"
        default: throw MundaneTimespineStorageError.invalidCentrality(raw)
        }
    }
}
