import Foundation

public struct AtlasProvenance: Hashable, Codable, Sendable {
    public let version: String
    public let sourceDescription: String

    fileprivate init(version: String, sourceDescription: String) {
        self.version = version
        self.sourceDescription = sourceDescription
    }
}

public struct Topos: Hashable, Codable, Sendable {
    public let place: Place
    public let provenance: AtlasProvenance

    fileprivate init(place: Place, provenance: AtlasProvenance) {
        self.place = place
        self.provenance = provenance
    }
}

public enum AtlasResolution: Equatable, Sendable {
    case found(Topos)
    case ambiguous([Topos])
    case notFound
}

public enum AtlasEngravingResolution: Equatable, Sendable {
    case found(AtlasEngraving)
    case ambiguous([Topos])
    case notFound
}

public struct Atlas: Sendable {
    public init() {}

    public func resolve(_ query: String) -> AtlasResolution {
        switch GeoplacementAtlas.resolve(query) {
        case let .found(place):
            return .found(topos(for: place))
        case let .ambiguous(places):
            return .ambiguous(places.map(topos(for:)))
        case .notFound:
            return .notFound
        }
    }

    /// Atlas reads only the birth location and adds authoritative Topos.
    public func resolve(_ intake: EngravingIntake) -> AtlasEngravingResolution {
        switch resolve(intake.birthLocation) {
        case let .found(topos):
            return .found(AtlasEngraving(intake: intake, topos: topos))
        case let .ambiguous(topoi):
            return .ambiguous(topoi)
        case .notFound:
            return .notFound
        }
    }

    private var provenance: AtlasProvenance {
        AtlasProvenance(
            version: GeoplacementAtlas.version,
            sourceDescription: GeoplacementAtlas.sourceDescription
        )
    }

    private func topos(for place: Place) -> Topos {
        Topos(place: place, provenance: provenance)
    }
}
