import Foundation

/// Compact candidate-derived address map for station second strikes. The first station pass keeps
/// its existing deterministic question order; this map exists only so a fresh Pollux can rebuild
/// one disputed celestial station without recreating or searching the whole station question set.
struct PolluxStationDirectLookup: Sendable {
    static let law = "celestial station identity -> compact candidate index -> civic occurrence"

    let candidateSHA256: String
    private let civicOffsetByAddress: [PolluxStationAddress: Int64]

    init(candidateSHA256: String, storage: MundaneTimespineStorageImage) throws {
        self.candidateSHA256 = candidateSHA256
        var index: [PolluxStationAddress: Int64] = [:]
        index.reserveCapacity(storage.bodies.reduce(0) { $0 + $1.stations.count })

        for body in storage.bodies {
            for station in body.stations {
                let address = Self.address(body: body.body, station: station)
                guard index.updateValue(station.civicOffsetSeconds, forKey: address) == nil else {
                    throw PolluxError.ambiguousStationIdentity(
                        body: body.body,
                        celestialMicrodegrees: station.celestialMicrodegrees
                    )
                }
            }
        }
        self.civicOffsetByAddress = index
    }

    func question(for address: PolluxStationAddress) -> PolluxStationQuestion? {
        guard let civicOffsetSeconds = civicOffsetByAddress[address] else { return nil }
        return PolluxStationQuestion(
            address: address,
            handoff: PolluxCivicHandoff(
                candidateSHA256: candidateSHA256,
                civicOffsetSeconds: civicOffsetSeconds
            )
        )
    }

    static func address(
        body: MundaneBody,
        station: MundaneTimespineStoredStation
    ) -> PolluxStationAddress {
        PolluxStationAddress(
            body: body,
            celestialMicrodegrees: station.celestialMicrodegrees,
            motionAfter: station.motionAfter
        )
    }
}

/// Compact candidate-derived address map for eclipse second strikes. Eclipse identity remains
/// celestial-first; civic time is recovered only after the exact eclipse address is supplied.
struct PolluxEclipseDirectLookup: Sendable {
    static let law = "celestial eclipse identity -> compact candidate index -> civic occurrence"

    let candidateSHA256: String
    private let civicOffsetByAddress: [PolluxEclipseAddress: Int64]

    init(candidateSHA256: String, storage: MundaneTimespineStorageImage) throws {
        self.candidateSHA256 = candidateSHA256
        var index: [PolluxEclipseAddress: Int64] = [:]
        index.reserveCapacity(storage.eclipses.count)

        for event in storage.eclipses {
            let address = Self.address(for: event)
            let offset = Int64(((event.julianDay.value - storage.supportedStart.value) * 86_400).rounded())
            guard index.updateValue(offset, forKey: address) == nil else {
                throw PolluxError.ambiguousEclipseIdentity
            }
        }
        self.civicOffsetByAddress = index
    }

    func question(for address: PolluxEclipseAddress) -> PolluxEclipseQuestion? {
        guard let civicOffsetSeconds = civicOffsetByAddress[address] else { return nil }
        return PolluxEclipseQuestion(
            address: address,
            handoff: PolluxCivicHandoff(
                candidateSHA256: candidateSHA256,
                civicOffsetSeconds: civicOffsetSeconds
            )
        )
    }

    static func address(for event: MundaneTimespineEclipseEvent) -> PolluxEclipseAddress {
        PolluxEclipseAddress(
            kind: event.kind,
            type: event.type,
            eclipseMicrodegrees: MundaneTimespineStorageImage.microdegrees(event.eclipseDegree),
            centrality: event.centrality,
            magnitudeBits: event.magnitude?.bitPattern,
            secondaryMagnitudeBits: event.secondaryMagnitude?.bitPattern
        )
    }
}

extension Pollux {
    public static let stationSecondStrikeLookupLaw = PolluxStationDirectLookup.law
    public static let eclipseSecondStrikeLookupLaw = PolluxEclipseDirectLookup.law

    func makeStationDirectLookup(
        storage: MundaneTimespineStorageImage
    ) throws -> PolluxStationDirectLookup {
        try PolluxStationDirectLookup(candidateSHA256: candidateSHA256, storage: storage)
    }

    func reconstructStationQuestion(
        _ address: PolluxStationAddress,
        using lookup: PolluxStationDirectLookup
    ) -> PolluxStationQuestion? {
        guard lookup.candidateSHA256 == candidateSHA256 else { return nil }
        return lookup.question(for: address)
    }

    func makeEclipseDirectLookup(
        storage: MundaneTimespineStorageImage
    ) throws -> PolluxEclipseDirectLookup {
        try PolluxEclipseDirectLookup(candidateSHA256: candidateSHA256, storage: storage)
    }

    func reconstructEclipseQuestion(
        _ address: PolluxEclipseAddress,
        using lookup: PolluxEclipseDirectLookup
    ) -> PolluxEclipseQuestion? {
        guard lookup.candidateSHA256 == candidateSHA256 else { return nil }
        return lookup.question(for: address)
    }
}
