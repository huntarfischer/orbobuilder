public enum DignityRung: String, CaseIterable, Codable, Hashable, Sendable {
    case domicile
    case exaltation
    case triplicity
    case bound
    case face
}

public enum EssentialDebility: String, CaseIterable, Codable, Hashable, Sendable {
    case detriment
    case fall
}

public enum BoundsScheme: String, CaseIterable, Codable, Hashable, Sendable {
    case egyptian
}

public enum TriplicityScheme: String, CaseIterable, Codable, Hashable, Sendable {
    case dorothean
}

public enum FaceScheme: String, CaseIterable, Codable, Hashable, Sendable {
    case chaldean
}

public struct DignityDoctrine: Hashable, Codable, Sendable {
    public let bounds: BoundsScheme
    public let triplicity: TriplicityScheme
    public let faces: FaceScheme

    public init(
        bounds: BoundsScheme,
        triplicity: TriplicityScheme,
        faces: FaceScheme
    ) {
        self.bounds = bounds
        self.triplicity = triplicity
        self.faces = faces
    }

    public static let orboDefault = DignityDoctrine(
        bounds: .egyptian,
        triplicity: .dorothean,
        faces: .chaldean
    )
}

public struct Exaltation: Hashable, Codable, Sendable {
    public let planet: Planet
    public let sign: Sign
    public let degree: DegreeInSign

    public init(planet: Planet, sign: Sign, degree: DegreeInSign) {
        self.planet = planet
        self.sign = sign
        self.degree = degree
    }
}

public struct Bound: Hashable, Sendable {
    public let ruler: Planet
    public let sign: Sign
    public let start: DegreeBoundaryInSign
    public let end: DegreeBoundaryInSign
    public let scheme: BoundsScheme

    /// Bounds are half-open [start, end). A legal interval must advance and
    /// may end at 30 exactly.
    public init?(
        ruler: Planet,
        sign: Sign,
        start: DegreeBoundaryInSign,
        end: DegreeBoundaryInSign,
        scheme: BoundsScheme
    ) {
        guard start.value < end.value else { return nil }
        self.ruler = ruler
        self.sign = sign
        self.start = start
        self.end = end
        self.scheme = scheme
    }
}

public struct Face: Hashable, Sendable {
    public let ruler: Planet
    public let sign: Sign
    public let decan: Int
    public let scheme: FaceScheme

    public init?(ruler: Planet, sign: Sign, decan: Int, scheme: FaceScheme) {
        guard (1...3).contains(decan) else { return nil }
        self.ruler = ruler
        self.sign = sign
        self.decan = decan
        self.scheme = scheme
    }
}

public struct Triplicity: Hashable, Sendable {
    public let element: Element
    public let dayRuler: Planet
    public let nightRuler: Planet
    public let participatingRuler: Planet
    public let scheme: TriplicityScheme

    public init(
        element: Element,
        dayRuler: Planet,
        nightRuler: Planet,
        participatingRuler: Planet,
        scheme: TriplicityScheme
    ) {
        self.element = element
        self.dayRuler = dayRuler
        self.nightRuler = nightRuler
        self.participatingRuler = participatingRuler
        self.scheme = scheme
    }

    public func operativeRuler(for sect: Sect?) -> Planet? {
        switch sect {
        case .day:
            return dayRuler
        case .night:
            return nightRuler
        case nil:
            return nil
        }
    }
}

public struct EssentialCondition: Hashable, Sendable {
    public let planet: Planet
    public let longitude: CelestialLongitude
    public let dignities: Set<DignityRung>
    public let debilities: Set<EssentialDebility>
    public let bound: Bound
    public let face: Face
    public let triplicity: Triplicity

    /// Classical essential dignity is defined only for the traditional seven
    /// at this layer. Modern planets are rejected rather than assigned an
    /// empty ladder that could be mistaken for peregrine status.
    public init?(
        planet: Planet,
        longitude: CelestialLongitude,
        dignities: Set<DignityRung>,
        debilities: Set<EssentialDebility>,
        bound: Bound,
        face: Face,
        triplicity: Triplicity
    ) {
        guard planet.isClassical else { return nil }
        self.planet = planet
        self.longitude = longitude
        self.dignities = dignities
        self.debilities = debilities
        self.bound = bound
        self.face = face
        self.triplicity = triplicity
    }

    public var isPeregrine: Bool {
        dignities.isEmpty
    }
}
