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

public enum EngravingAtlasResolution: Equatable, Sendable {
    case found(Engraving)
    case ambiguous([Topos])
    case ambiguousTempus(first: Engraving, second: Engraving)
    case nonexistentCivilTime(Engraving)
    case unknownTimeZone(Engraving, TimezoneIdentifier)
    case unsupportedYear(Engraving, Int)
    case unsupportedCalendar(Engraving, CivilCalendar)
    case notFound
}

public typealias EngravingToposResolution = EngravingAtlasResolution

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

    /// Atlas establishes the Engraving's earthly event by resolving Topos first,
    /// then resolving the local civil reading into Tempus through existing CivilTime law.
    /// The object remains the same Engraving throughout its courier journey.
    public func resolve(_ engraving: Engraving) -> EngravingAtlasResolution {
        switch resolve(engraving.birthLocation) {
        case let .found(topos):
            return resolveTempus(for: engraving.resolving(topos: topos), at: topos)
        case let .ambiguous(topoi):
            return .ambiguous(topoi)
        case .notFound:
            return .notFound
        }
    }

    private func resolveTempus(for engraving: Engraving, at topos: Topos) -> EngravingAtlasResolution {
        switch CivilTime.resolve(
            date: engraving.birthDate,
            time: engraving.birthTime,
            in: topos.place.timezone
        ) {
        case let .resolved(match):
            return .found(engraving.resolving(tempus: tempus(for: match)))
        case let .ambiguous(first, second):
            return .ambiguousTempus(
                first: engraving.resolving(tempus: tempus(for: first)),
                second: engraving.resolving(tempus: tempus(for: second))
            )
        case .nonexistent:
            return .nonexistentCivilTime(engraving)
        case let .unknownTimeZone(identifier):
            return .unknownTimeZone(engraving, identifier)
        case let .unsupportedYear(year):
            return .unsupportedYear(engraving, year)
        case let .unsupportedCalendar(calendar):
            return .unsupportedCalendar(engraving, calendar)
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

    private func tempus(for match: CivilTimeMatch) -> Tempus {
        Tempus(
            absoluteInstant: match.instant,
            provenance: TempusProvenance(
                source: match.source,
                timeZoneDataVersion: match.source == .timeZoneDatabase
                    ? CivilTime.timeZoneDataVersion
                    : nil
            )
        )
    }
}
