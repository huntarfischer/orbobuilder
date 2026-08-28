public enum ClothoFailure: Error, Hashable, Sendable {
    case unresolvedTopos
    case unresolvedTempus
    case astroDNAAlreadyResolved
    case missingUniversalBody(MundaneBody)
    case invalidAscendant
    case invalidAstroDNA
}

/// Door One is the single OrboSpine doorway Clotho uses for natal work.
///
/// Clotho supplies the resolved Tempus. The query returns one Horae cross-section:
/// the universal celestial coordinates plus the matching Terra state. Door One
/// does not know Topos and does not construct local angles or AstroDNA.
public protocol ClothoPortI {
    mutating func queryNatalSlice(at tempus: Tempus) throws -> HoraeOutput
}

public struct ClothoOutput: Hashable, Sendable {
    public let engraving: Engraving
    public let packet: PatternPacket

    fileprivate init(
        engraving: Engraving,
        packet: PatternPacket
    ) {
        self.engraving = engraving
        self.packet = packet
    }
}

/// Clotho gathers established matter and asks Hecate to cast from it.
/// Clotho performs no chart formulae herself.
public enum Clotho {
    public static func spin<Port: ClothoPortI>(
        _ engraving: Engraving,
        through portI: inout Port
    ) throws -> ClothoOutput {
        guard let topos = engraving.topos else {
            throw ClothoFailure.unresolvedTopos
        }
        guard let tempus = engraving.tempus else {
            throw ClothoFailure.unresolvedTempus
        }
        guard engraving.astroDNA == nil else {
            throw ClothoFailure.astroDNAAlreadyResolved
        }

        let slice = try portI.queryNatalSlice(at: tempus)
        var coordinates: [MundaneBody: OrboSpineCelestialCoordinate] = [:]
        for coordinate in slice.celestial {
            coordinates[coordinate.body] = coordinate
        }

        for body in MundaneBody.canonicalOrder where coordinates[body] == nil {
            throw ClothoFailure.missingUniversalBody(body)
        }

        var nodeStates: [AstroDNAGene: RingFineState] = [:]
        for body in MundaneBody.canonicalOrder {
            let coordinate = coordinates[body]!
            let longitude = CelestialLongitude(
                coordinate.directionalDegree.physicalDegrees
            )!
            nodeStates[gene(for: body)] = Ring.fineState(
                of: longitude,
                motion: coordinate.directionalDegree.motion
            )
        }

        let ascendantState: RingFineState
        do {
            ascendantState = try Hecate.castAscendant(
                terra: slice.terra,
                topos: topos
            )
        } catch {
            throw ClothoFailure.invalidAscendant
        }
        nodeStates[.ascendant] = ascendantState

        let astroDNA: AstroDNA
        do {
            astroDNA = try Hecate.castAstroDNA(using: nodeStates)
        } catch {
            throw ClothoFailure.invalidAstroDNA
        }

        let ascendant = longitude(from: ascendantState)
        let sun = longitude(for: .sun, in: coordinates)
        let moon = longitude(for: .moon, in: coordinates)
        let venus = longitude(for: .venus, in: coordinates)
        let mercury = longitude(for: .mercury, in: coordinates)

        let sect = try Hecate.castSect(
            ascendant: ascendant,
            sun: sun
        )
        let fortune = try Hecate.castFortune(
            ascendant: ascendant,
            moon: moon,
            sun: sun,
            sect: sect
        )
        let spirit = try Hecate.castSpirit(
            ascendant: ascendant,
            sun: sun,
            moon: moon,
            sect: sect
        )
        let eros = try Hecate.castEros(
            ascendant: ascendant,
            venus: venus,
            spirit: spirit,
            sect: sect
        )
        let necessity = try Hecate.castNecessity(
            ascendant: ascendant,
            fortune: fortune,
            mercury: mercury,
            sect: sect
        )

        let resolvedEngraving = engraving.resolving(astroDNA: astroDNA)
        let packet = PatternPacket(
            pattern: .engraving,
            astroDNA: astroDNA,
            sect: sect,
            fortune: fortune,
            spirit: spirit,
            eros: eros,
            necessity: necessity
        )

        return ClothoOutput(
            engraving: resolvedEngraving,
            packet: packet
        )
    }

    private static func gene(for body: MundaneBody) -> AstroDNAGene {
        switch body {
        case .sun: return .sun
        case .moon: return .moon
        case .mercury: return .mercury
        case .venus: return .venus
        case .mars: return .mars
        case .jupiter: return .jupiter
        case .saturn: return .saturn
        case .uranus: return .uranus
        case .neptune: return .neptune
        case .pluto: return .pluto
        case .trueNorthNode: return .northNode
        }
    }

    private static func longitude(
        for body: MundaneBody,
        in coordinates: [MundaneBody: OrboSpineCelestialCoordinate]
    ) -> CelestialLongitude {
        CelestialLongitude(coordinates[body]!.directionalDegree.physicalDegrees)!
    }

    private static func longitude(from state: RingFineState) -> CelestialLongitude {
        CelestialLongitude(
            Double(state.arcsecond) / Double(Ring.arcsecondsPerDegree)
        )!
    }
}
