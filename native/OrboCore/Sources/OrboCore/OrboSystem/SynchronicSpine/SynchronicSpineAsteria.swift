import Foundation

public enum SynchronicAsteriaFailure: Error, Hashable, Sendable {
    case sourceDoesNotCoverBone
    case outsideBone
    case invalidArcCoordinate
    case bodyUnavailable
}

/// The twelve native-local fields Asteria refracts through Synchronic Time.
/// Eleven pair a natal gene with the same mundane body; Terra pairs the
/// native Ascendant with the universal Horizon carried by Terra Marrow.
public enum SynchronicAsteriaBody: String, CaseIterable, Hashable, Sendable {
    case sun
    case moon
    case mercury
    case venus
    case mars
    case jupiter
    case saturn
    case uranus
    case neptune
    case pluto
    case northNode
    case terra

    public static let canonicalOrder: [SynchronicAsteriaBody] = [
        .sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn,
        .uranus, .neptune, .pluto, .northNode, .terra,
    ]

    public var natalGene: AstroDNAGene {
        switch self {
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
        case .northNode: return .northNode
        case .terra: return .ascendant
        }
    }

    public var mundaneBody: MundaneBody? {
        switch self {
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
        case .northNode: return .trueNorthNode
        case .terra: return nil
        }
    }
}

/// Provenance for the moving half of one Synchronic Asteria composition.
public enum SynchronicAsteriaMundaneSource: Hashable, Sendable {
    case celestial(OrboSpineCelestialCoordinate)
    case terra(TerraMarrowSample)
}

/// One addressable point on a continuous Synchronic Asteria Pass.
public struct SynchronicAsteriaMoment: Hashable, Sendable {
    public let subjectID: HermesSubjectID
    public let ticketID: HermesTicketID
    public let body: SynchronicAsteriaBody
    public let instant: AbsoluteInstant
    public let natalAnchor: ArcCoordinate
    public let mundanePartner: ArcCoordinate
    public let mundaneSource: SynchronicAsteriaMundaneSource
    public let composite: ArcComposite

    internal init(
        subjectID: HermesSubjectID,
        ticketID: HermesTicketID,
        body: SynchronicAsteriaBody,
        instant: AbsoluteInstant,
        natalAnchor: ArcCoordinate,
        mundanePartner: ArcCoordinate,
        mundaneSource: SynchronicAsteriaMundaneSource,
        composite: ArcComposite
    ) {
        self.subjectID = subjectID
        self.ticketID = ticketID
        self.body = body
        self.instant = instant
        self.natalAnchor = natalAnchor
        self.mundanePartner = mundanePartner
        self.mundaneSource = mundaneSource
        self.composite = composite
    }
}

/// One of the twelve continuous Asteria Passes required by the Pattern.
/// It stores no sampled Synchronic ephemeris. The already-forged OrboSpine is
/// resolved at the requested UT and Asteria applies Arc exactly once.
public struct SynchronicAsteriaPass: Sendable {
    public let subjectID: HermesSubjectID
    public let ticketID: HermesTicketID
    public let body: SynchronicAsteriaBody
    public let bone: SynchronicSpineBone
    public let natalAnchor: ArcCoordinate

    private let locate: OrboSpineLocate

    internal init(
        subjectID: HermesSubjectID,
        ticketID: HermesTicketID,
        body: SynchronicAsteriaBody,
        bone: SynchronicSpineBone,
        natalAnchor: ArcCoordinate,
        locate: OrboSpineLocate
    ) {
        self.subjectID = subjectID
        self.ticketID = ticketID
        self.body = body
        self.bone = bone
        self.natalAnchor = natalAnchor
        self.locate = locate
    }

    public func resolve(at instant: AbsoluteInstant) throws -> SynchronicAsteriaMoment {
        guard bone.contains(instant) else { throw SynchronicAsteriaFailure.outsideBone }

        let julianDay = instant.julianDay
        let source: SynchronicAsteriaMundaneSource
        let partner: ArcCoordinate

        if let mundaneBody = body.mundaneBody {
            let coordinate: OrboSpineCelestialCoordinate
            do {
                coordinate = try locate.coordinate(of: mundaneBody, at: julianDay)
            } catch OrboSpineLocateError.bodyUnavailable {
                throw SynchronicAsteriaFailure.bodyUnavailable
            }
            source = .celestial(coordinate)
            partner = try Self.arcCoordinate(fromDegrees: coordinate.directionalDegree.physicalDegrees)
        } else {
            let terra: TerraMarrowSample
            do {
                terra = try locate.terra(at: julianDay)
            } catch OrboSpineLocateError.terraUnavailable {
                throw SynchronicAsteriaFailure.bodyUnavailable
            }
            source = .terra(terra)
            partner = try Self.arcCoordinate(fromDegrees: terra.turnDegrees)
        }

        return SynchronicAsteriaMoment(
            subjectID: subjectID,
            ticketID: ticketID,
            body: body,
            instant: instant,
            natalAnchor: natalAnchor,
            mundanePartner: partner,
            mundaneSource: source,
            composite: Asteria.refract(natalAnchor, with: partner)
        )
    }

    private static func arcCoordinate(fromDegrees degrees: Double) throws -> ArcCoordinate {
        guard degrees.isFinite else { throw SynchronicAsteriaFailure.invalidArcCoordinate }
        var normalized = degrees.truncatingRemainder(dividingBy: 360)
        if normalized < 0 { normalized += 360 }

        // Arc's frozen input vocabulary is whole arcseconds. OrboSpine keeps its
        // finer continuous interpolation; this is only the address admitted at
        // the Arc seam, not a second celestial calculation.
        var raw = Int((normalized * Double(Arc.arcsecondsPerDegree)).rounded())
        if raw == Arc.inputStates { raw = 0 }
        guard let coordinate = ArcCoordinate(raw) else {
            throw SynchronicAsteriaFailure.invalidArcCoordinate
        }
        return coordinate
    }
}

public struct SynchronicAsteriaField: Sendable {
    public let subjectID: HermesSubjectID
    public let ticketID: HermesTicketID
    public let bone: SynchronicSpineBone
    public let passes: [SynchronicAsteriaPass]

    internal init(
        subjectID: HermesSubjectID,
        ticketID: HermesTicketID,
        bone: SynchronicSpineBone,
        passes: [SynchronicAsteriaPass]
    ) {
        self.subjectID = subjectID
        self.ticketID = ticketID
        self.bone = bone
        self.passes = passes
    }

    public subscript(_ body: SynchronicAsteriaBody) -> SynchronicAsteriaPass? {
        passes.first { $0.body == body }
    }
}

public extension Lachesis {
    /// Calls Asteria once for each of the twelve Pattern bodies without
    /// sampling time or reopening ephemeris work.
    static func callAsteriaForSynchronicSpine(
        foundation: SynchronicSpineFoundation,
        natalAstroDNA: AstroDNA,
        mundaneSpine: OrboSpineLocate
    ) throws -> SynchronicAsteriaField {
        guard
            mundaneSpine.bone.contains(foundation.bone.start.julianDay),
            mundaneSpine.bone.contains(foundation.bone.end.julianDay)
        else {
            throw SynchronicAsteriaFailure.sourceDoesNotCoverBone
        }

        let passes = SynchronicAsteriaBody.canonicalOrder.map { body in
            let natalState = natalAstroDNA[body.natalGene]
            let natalAnchor = ArcCoordinate(natalState.arcsecond)!
            return SynchronicAsteriaPass(
                subjectID: foundation.commission.subjectID,
                ticketID: foundation.commission.ticketID,
                body: body,
                bone: foundation.bone,
                natalAnchor: natalAnchor,
                locate: mundaneSpine
            )
        }

        return SynchronicAsteriaField(
            subjectID: foundation.commission.subjectID,
            ticketID: foundation.commission.ticketID,
            bone: foundation.bone,
            passes: passes
        )
    }
}
