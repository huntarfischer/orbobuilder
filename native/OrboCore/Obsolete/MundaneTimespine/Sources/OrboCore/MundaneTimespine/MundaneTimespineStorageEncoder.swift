import Foundation

extension MundaneTimespineStorageImage {
    public func encodedArtifact() throws -> Data {
        guard MundaneTimespineStorageFormat.celestialTimeFirst else {
            throw MundaneTimespineStorageError.celestialTimeLawMissing
        }

        var payloads: [(kind: MundaneTimespineStorageSectionKind, body: MundaneBody?, count: Int, data: Data)] = []
        payloads.append((.metadata, nil, 1, try encodeMetadata()))
        payloads.append((.boundaries, nil, boundaryStates.count, try encodeBoundaries()))
        for body in bodies {
            payloads.append((.body, body.body, body.occurrences.count, try encodeBody(body)))
        }
        payloads.append((.relationships, nil, relationships.count, try encodeRelationships()))
        payloads.append((.eclipses, nil, eclipses.count, try encodeEclipses()))

        guard payloads.count <= Int(UInt16.max) else { throw MundaneTimespineStorageError.integerOverflow }
        let fixedHeaderBytes = 32
        let directoryEntryBytes = 24
        let payloadStart = fixedHeaderBytes + directoryEntryBytes * payloads.count
        var runningOffset = payloadStart
        var sections: [MundaneTimespineStorageSection] = []
        sections.reserveCapacity(payloads.count)
        for payload in payloads {
            sections.append(
                MundaneTimespineStorageSection(
                    kind: payload.kind,
                    body: payload.body,
                    offset: runningOffset,
                    length: payload.data.count,
                    recordCount: payload.count
                )
            )
            runningOffset += payload.data.count
        }

        var writer = MundaneTimespineBinaryWriter()
        writer.bytes(MundaneTimespineStorageFormat.magic)
        writer.u16(MundaneTimespineStorageFormat.version)
        writer.u16(1) // bit 0: celestial-time-first
        writer.f64(supportedStart.value)
        writer.f64(supportedEnd.value)
        writer.u16(UInt16(sections.count))
        writer.u16(0)

        for section in sections {
            writer.byte(section.kind.rawValue)
            writer.byte(section.body?.rawValue ?? 0xff)
            writer.u16(0)
            writer.u64(UInt64(section.offset))
            writer.u64(UInt64(section.length))
            guard section.recordCount <= Int(UInt32.max) else { throw MundaneTimespineStorageError.integerOverflow }
            writer.u32(UInt32(section.recordCount))
        }
        for payload in payloads { writer.data.append(payload.data) }
        return writer.data
    }

    private func encodeMetadata() throws -> Data {
        var writer = MundaneTimespineBinaryWriter()
        writer.string(spanName)
        writer.string(astronomicalSource)
        writer.string(astronomicalSourceVersion)
        return writer.data
    }

    private func encodeBoundaries() throws -> Data {
        var writer = MundaneTimespineBinaryWriter()
        for state in boundaryStates {
            writer.byte(state.body.rawValue)
            writer.varUInt(UInt64(state.startCelestialMicrodegrees))
            writer.byte(state.startMotion == .retrograde ? 1 : 0)
            writer.varUInt(UInt64(state.endCelestialMicrodegrees))
            writer.byte(state.endMotion == .retrograde ? 1 : 0)
        }
        return writer.data
    }

    private func encodeBody(_ body: MundaneTimespineStoredBody) throws -> Data {
        var writer = MundaneTimespineBinaryWriter()
        writer.varUInt(UInt64(body.ticksPerDegree))
        writer.varUInt(UInt64(body.markerBodies.count))
        for marker in body.markerBodies { writer.byte(marker.rawValue) }
        writer.varUInt(UInt64(body.occurrences.count))
        writer.varUInt(UInt64(body.stations.count))
        writer.varUInt(UInt64(body.retrogradePassages.count))

        var previousOffset: Int64 = 0
        for row in body.occurrences {
            guard row.civicOffsetSeconds >= previousOffset else { throw MundaneTimespineStorageError.malformedImage }
            writer.varUInt(UInt64(row.celestialTick))
            writer.varUInt(UInt64(row.civicOffsetSeconds - previousOffset))
            writer.byte(row.sequenceDirection == .decreasing ? 1 : 0)
            for marker in row.markerWholeDegrees { writer.varUInt(UInt64(marker)) }
            previousOffset = row.civicOffsetSeconds
        }

        for station in body.stations {
            writer.varUInt(UInt64(station.celestialMicrodegrees))
            guard station.civicOffsetSeconds >= 0 else { throw MundaneTimespineStorageError.malformedImage }
            writer.varUInt(UInt64(station.civicOffsetSeconds))
            writer.byte(station.motionAfter == .retrograde ? 1 : 0)
        }
        for passage in body.retrogradePassages {
            writer.varUInt(UInt64(passage.startCelestialMicrodegrees))
            writer.varUInt(UInt64(passage.endCelestialMicrodegrees))
            guard passage.startCivicOffsetSeconds >= 0,
                  passage.endCivicOffsetSeconds >= passage.startCivicOffsetSeconds else {
                throw MundaneTimespineStorageError.malformedImage
            }
            writer.varUInt(UInt64(passage.startCivicOffsetSeconds))
            writer.varUInt(UInt64(passage.endCivicOffsetSeconds))
        }
        return writer.data
    }

    private func encodeRelationships() throws -> Data {
        var writer = MundaneTimespineBinaryWriter()
        var previousOffset: Int64 = 0
        for event in relationships {
            let civicOffset = Int64(((event.julianDay.value - supportedStart.value) * 86_400).rounded())
            guard civicOffset >= previousOffset else { throw MundaneTimespineStorageError.malformedImage }
            try validateOrientation(event)
            writer.byte((event.bodyA.rawValue << 4) | event.bodyB.rawValue)
            writer.byte(UInt8(event.mark.rawValue))
            writer.byte(orientationCode(event.orientation))
            writer.varUInt(UInt64(Self.microdegrees(event.bodyACelestialTimeDegrees)))
            writer.varUInt(UInt64(civicOffset - previousOffset))
            previousOffset = civicOffset
        }
        return writer.data
    }

    private func encodeEclipses() throws -> Data {
        var writer = MundaneTimespineBinaryWriter()
        var previousOffset: Int64 = 0
        for event in eclipses {
            let civicOffset = Int64(((event.julianDay.value - supportedStart.value) * 86_400).rounded())
            guard civicOffset >= previousOffset else { throw MundaneTimespineStorageError.malformedImage }
            writer.varUInt(UInt64(Self.microdegrees(event.eclipseDegree)))
            writer.byte(event.kind == .lunar ? 1 : 0)
            writer.byte(try eclipseTypeCode(event.type))
            writer.byte(try centralityCode(event.centrality))
            var options: UInt8 = 0
            if event.greatestEclipseJulianDay != nil { options |= 1 }
            if event.magnitude != nil { options |= 2 }
            if event.secondaryMagnitude != nil { options |= 4 }
            writer.byte(options)
            writer.varUInt(UInt64(civicOffset - previousOffset))
            if let greatest = event.greatestEclipseJulianDay {
                let delta = Int64(((greatest.value - event.julianDay.value) * 86_400).rounded())
                writer.varInt(delta)
            }
            if let magnitude = event.magnitude { writer.f64(magnitude) }
            if let secondary = event.secondaryMagnitude { writer.f64(secondary) }
            previousOffset = civicOffset
        }
        return writer.data
    }

    private func validateOrientation(_ event: MundaneTimespineRelationshipEvent) throws {
        switch event.mark {
        case .conjunction:
            guard event.orientation == .sameDegree else { throw MundaneTimespineStorageError.malformedImage }
        case .opposition:
            guard event.orientation == .oppositeDegree else { throw MundaneTimespineStorageError.malformedImage }
        default:
            guard event.orientation == .bodyAAhead || event.orientation == .bodyBAhead else {
                throw MundaneTimespineStorageError.malformedImage
            }
        }
    }

    private func orientationCode(_ value: MundaneTimespineRelationshipOrientation) -> UInt8 {
        switch value {
        case .sameDegree: return 0
        case .oppositeDegree: return 1
        case .bodyAAhead: return 2
        case .bodyBAhead: return 3
        }
    }

    private func eclipseTypeCode(_ value: MundaneTimespineEclipseType) throws -> UInt8 {
        switch value {
        case .total: return 0
        case .annular: return 1
        case .hybrid: return 2
        case .partial: return 3
        case .penumbral: return 4
        }
    }

    private func centralityCode(_ value: String?) throws -> UInt8 {
        switch value {
        case nil, "": return 0
        case "central": return 1
        case "noncentral": return 2
        default: throw MundaneTimespineStorageError.malformedImage
        }
    }
}
