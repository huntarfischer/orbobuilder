import Foundation

struct PolluxStationAddress: Hashable, Sendable {
    let body: MundaneBody
    let celestialMicrodegrees: UInt32
    let motionAfter: Motion
}

struct PolluxStationQuestion: Hashable, Sendable {
    let address: PolluxStationAddress
    let handoff: PolluxCivicHandoff
}

struct PolluxRelationshipAddress: Hashable, Sendable {
    let bodyA: MundaneBody
    let bodyB: MundaneBody
    let mark: RingMark
    let orientation: MundaneTimespineRelationshipOrientation
    let bodyAMicrodegrees: UInt32
    let bodyBMicrodegrees: UInt32
    let recurrenceOrdinal: Int
}

struct PolluxRelationshipQuestion: Hashable, Sendable {
    let address: PolluxRelationshipAddress
    let handoff: PolluxCivicHandoff
}

struct PolluxEclipseAddress: Hashable, Sendable {
    let kind: MundaneTimespineEclipseKind
    let type: MundaneTimespineEclipseType
    let eclipseMicrodegrees: UInt32
    let centrality: String?
    let magnitudeBits: UInt64?
    let secondaryMagnitudeBits: UInt64?
}

struct PolluxEclipseQuestion: Hashable, Sendable {
    let address: PolluxEclipseAddress
    let handoff: PolluxCivicHandoff
}

/// Streaming relationship cursor. Exact celestial geometry may recur during a multi-century
/// Timespine. Pollux therefore qualifies each repeated geometry by its zero-based recurrence
/// ordinal inside that geometry's own occurrence sequence. Civic UT is still excluded from the
/// celestial address and is discovered only after the qualified celestial identity is chosen.
struct PolluxRelationshipQuestionCursor: Sendable {
    private let candidateSHA256: String
    private let supportedStart: JulianDay
    private let relationships: [MundaneTimespineRelationshipEvent]
    private var position = 0
    private var recurrenceCounts: [PolluxRelationshipDirectLookup.CelestialKey: Int] = [:]
    private var lastOffsetByKey: [PolluxRelationshipDirectLookup.CelestialKey: Int64] = [:]

    init(candidateSHA256: String, storage: MundaneTimespineStorageImage) {
        self.candidateSHA256 = candidateSHA256
        self.supportedStart = storage.supportedStart
        self.relationships = storage.relationships
        self.recurrenceCounts.reserveCapacity(storage.relationships.count)
        self.lastOffsetByKey.reserveCapacity(storage.relationships.count)
    }

    mutating func seek(to completed: Int) throws {
        guard (0...relationships.count).contains(completed) else {
            throw PolluxError.candidateContractMismatch
        }
        position = 0
        recurrenceCounts.removeAll(keepingCapacity: true)
        lastOffsetByKey.removeAll(keepingCapacity: true)
        if completed > 0 {
            for index in 0..<completed {
                _ = try qualify(relationships[index])
            }
        }
        position = completed
    }

    mutating func next() throws -> PolluxRelationshipQuestion? {
        guard position < relationships.count else { return nil }
        let event = relationships[position]
        position += 1
        let qualified = try qualify(event)
        return PolluxRelationshipQuestion(
            address: qualified.address,
            handoff: PolluxCivicHandoff(
                candidateSHA256: candidateSHA256,
                civicOffsetSeconds: qualified.offset
            )
        )
    }

    private mutating func qualify(
        _ event: MundaneTimespineRelationshipEvent
    ) throws -> (address: PolluxRelationshipAddress, offset: Int64) {
        let baseAddress = PolluxRelationshipDirectLookup.address(for: event)
        let key = PolluxRelationshipDirectLookup.key(for: baseAddress)
        let offset = Int64(((event.julianDay.value - supportedStart.value) * 86_400).rounded())

        // Repeated celestial geometry at a later civic occurrence is valid. The same qualified
        // geometry at the same stored second would instead be a duplicate source occurrence.
        if lastOffsetByKey[key] == offset {
            throw PolluxError.ambiguousRelationshipIdentity
        }

        let ordinal = recurrenceCounts[key, default: 0]
        recurrenceCounts[key] = ordinal + 1
        lastOffsetByKey[key] = offset
        return (
            PolluxRelationshipDirectLookup.address(
                for: event,
                recurrenceOrdinal: ordinal
            ),
            offset
        )
    }
}

/// Alternate relationship path used only after a first-strike divergence. It builds a compact
/// celestial recurrence index lazily, once, and thereafter resolves the disputed relationship
/// directly. The first strike still streams independently through PolluxRelationshipQuestionCursor.
struct PolluxRelationshipDirectLookup: Sendable {
    static let recurrenceLaw = "exact celestial geometry + recurrence ordinal / civic UT excluded"
    static let law = "qualified celestial relationship identity -> compact candidate index -> civic occurrence"

    struct CelestialKey: Hashable, Sendable {
        let high: UInt64
        let low: UInt64
    }

    private struct OccurrenceKey: Hashable, Sendable {
        let celestial: CelestialKey
        let recurrenceOrdinal: Int
    }

    let candidateSHA256: String
    private let supportedStart: JulianDay
    private let relationships: [MundaneTimespineRelationshipEvent]
    private let eventIndexByKey: [OccurrenceKey: Int]

    init(candidateSHA256: String, storage: MundaneTimespineStorageImage) throws {
        self.candidateSHA256 = candidateSHA256
        self.supportedStart = storage.supportedStart
        self.relationships = storage.relationships

        var index: [OccurrenceKey: Int] = [:]
        var recurrenceCounts: [CelestialKey: Int] = [:]
        var lastOffsetByKey: [CelestialKey: Int64] = [:]
        index.reserveCapacity(storage.relationships.count)
        recurrenceCounts.reserveCapacity(storage.relationships.count)
        lastOffsetByKey.reserveCapacity(storage.relationships.count)

        for eventIndex in storage.relationships.indices {
            let event = storage.relationships[eventIndex]
            let baseAddress = Self.address(for: event)
            let celestialKey = Self.key(for: baseAddress)
            let offset = Int64(((event.julianDay.value - storage.supportedStart.value) * 86_400).rounded())
            if lastOffsetByKey[celestialKey] == offset {
                throw PolluxError.ambiguousRelationshipIdentity
            }

            let ordinal = recurrenceCounts[celestialKey, default: 0]
            let occurrenceKey = OccurrenceKey(
                celestial: celestialKey,
                recurrenceOrdinal: ordinal
            )
            guard index.updateValue(eventIndex, forKey: occurrenceKey) == nil else {
                throw PolluxError.ambiguousRelationshipIdentity
            }
            recurrenceCounts[celestialKey] = ordinal + 1
            lastOffsetByKey[celestialKey] = offset
        }
        self.eventIndexByKey = index
    }

    func question(for address: PolluxRelationshipAddress) -> PolluxRelationshipQuestion? {
        guard address.recurrenceOrdinal >= 0 else { return nil }
        let occurrenceKey = OccurrenceKey(
            celestial: Self.key(for: address),
            recurrenceOrdinal: address.recurrenceOrdinal
        )
        guard let eventIndex = eventIndexByKey[occurrenceKey] else { return nil }
        let event = relationships[eventIndex]
        guard Self.address(
            for: event,
            recurrenceOrdinal: address.recurrenceOrdinal
        ) == address else {
            return nil
        }
        let offset = Int64(((event.julianDay.value - supportedStart.value) * 86_400).rounded())
        return PolluxRelationshipQuestion(
            address: address,
            handoff: PolluxCivicHandoff(
                candidateSHA256: candidateSHA256,
                civicOffsetSeconds: offset
            )
        )
    }

    static func address(
        for event: MundaneTimespineRelationshipEvent,
        recurrenceOrdinal: Int = 0
    ) -> PolluxRelationshipAddress {
        PolluxRelationshipAddress(
            bodyA: event.bodyA,
            bodyB: event.bodyB,
            mark: event.mark,
            orientation: event.orientation,
            bodyAMicrodegrees: MundaneTimespineStorageImage.microdegrees(event.bodyACelestialTimeDegrees),
            bodyBMicrodegrees: MundaneTimespineStorageImage.microdegrees(event.bodyBCelestialTimeDegrees),
            recurrenceOrdinal: recurrenceOrdinal
        )
    }

    static func key(for address: PolluxRelationshipAddress) -> CelestialKey {
        let orientation: UInt64
        switch address.orientation {
        case .sameDegree: orientation = 0
        case .oppositeDegree: orientation = 1
        case .bodyAAhead: orientation = 2
        case .bodyBAhead: orientation = 3
        }

        let high = UInt64(address.bodyA.rawValue)
            | (UInt64(address.bodyB.rawValue) << 4)
            | (UInt64(address.mark.rawValue) << 8)
            | (orientation << 16)
        let low = UInt64(address.bodyAMicrodegrees)
            | (UInt64(address.bodyBMicrodegrees) << 32)
        return CelestialKey(high: high, low: low)
    }
}

extension Pollux {
    public static let relationshipRecurrenceIdentityLaw = PolluxRelationshipDirectLookup.recurrenceLaw
    public static let relationshipSecondStrikeLookupLaw = PolluxRelationshipDirectLookup.law

    func makeStationQuestions(storage: MundaneTimespineStorageImage) throws -> [PolluxStationQuestion] {
        var seen = Set<PolluxStationAddress>()
        var result: [PolluxStationQuestion] = []

        for body in storage.bodies {
            for station in body.stations {
                let address = PolluxStationAddress(
                    body: body.body,
                    celestialMicrodegrees: station.celestialMicrodegrees,
                    motionAfter: station.motionAfter
                )
                guard seen.insert(address).inserted else {
                    throw PolluxError.ambiguousStationIdentity(
                        body: body.body,
                        celestialMicrodegrees: station.celestialMicrodegrees
                    )
                }
                result.append(PolluxStationQuestion(
                    address: address,
                    handoff: PolluxCivicHandoff(
                        candidateSHA256: candidateSHA256,
                        civicOffsetSeconds: station.civicOffsetSeconds
                    )
                ))
            }
        }

        return result.sorted {
            if $0.address.body.rawValue != $1.address.body.rawValue {
                return $0.address.body.rawValue < $1.address.body.rawValue
            }
            if $0.address.celestialMicrodegrees != $1.address.celestialMicrodegrees {
                return $0.address.celestialMicrodegrees < $1.address.celestialMicrodegrees
            }
            return $0.address.motionAfter.rawValue < $1.address.motionAfter.rawValue
        }
    }

    func makeRelationshipQuestionCursor(
        storage: MundaneTimespineStorageImage
    ) -> PolluxRelationshipQuestionCursor {
        PolluxRelationshipQuestionCursor(candidateSHA256: candidateSHA256, storage: storage)
    }

    func makeRelationshipQuestionCursor(
        storage: MundaneTimespineStorageImage,
        startingAt completed: Int
    ) throws -> PolluxRelationshipQuestionCursor {
        var cursor = PolluxRelationshipQuestionCursor(
            candidateSHA256: candidateSHA256,
            storage: storage
        )
        try cursor.seek(to: completed)
        return cursor
    }

    func makeRelationshipDirectLookup(
        storage: MundaneTimespineStorageImage
    ) throws -> PolluxRelationshipDirectLookup {
        try PolluxRelationshipDirectLookup(candidateSHA256: candidateSHA256, storage: storage)
    }

    func reconstructRelationshipQuestion(
        _ address: PolluxRelationshipAddress,
        using lookup: PolluxRelationshipDirectLookup
    ) -> PolluxRelationshipQuestion? {
        guard lookup.candidateSHA256 == candidateSHA256 else { return nil }
        return lookup.question(for: address)
    }

    /// Retained for focused tests. Full certification consumes the streaming cursor above instead
    /// of retaining a second copy of every relationship question.
    func makeRelationshipQuestions(storage: MundaneTimespineStorageImage) throws -> [PolluxRelationshipQuestion] {
        var cursor = makeRelationshipQuestionCursor(storage: storage)
        var result: [PolluxRelationshipQuestion] = []
        result.reserveCapacity(storage.relationships.count)
        while let question = try cursor.next() {
            result.append(question)
        }

        return result.sorted {
            if $0.address.bodyA.rawValue != $1.address.bodyA.rawValue {
                return $0.address.bodyA.rawValue < $1.address.bodyA.rawValue
            }
            if $0.address.bodyB.rawValue != $1.address.bodyB.rawValue {
                return $0.address.bodyB.rawValue < $1.address.bodyB.rawValue
            }
            if $0.address.bodyAMicrodegrees != $1.address.bodyAMicrodegrees {
                return $0.address.bodyAMicrodegrees < $1.address.bodyAMicrodegrees
            }
            if $0.address.bodyBMicrodegrees != $1.address.bodyBMicrodegrees {
                return $0.address.bodyBMicrodegrees < $1.address.bodyBMicrodegrees
            }
            if $0.address.mark.rawValue != $1.address.mark.rawValue {
                return $0.address.mark.rawValue < $1.address.mark.rawValue
            }
            if $0.address.orientation.rawValue != $1.address.orientation.rawValue {
                return $0.address.orientation.rawValue < $1.address.orientation.rawValue
            }
            return $0.address.recurrenceOrdinal < $1.address.recurrenceOrdinal
        }
    }

    func makeEclipseQuestions(storage: MundaneTimespineStorageImage) throws -> [PolluxEclipseQuestion] {
        var seen = Set<PolluxEclipseAddress>()
        var result: [PolluxEclipseQuestion] = []
        result.reserveCapacity(storage.eclipses.count)

        for event in storage.eclipses {
            let address = PolluxEclipseAddress(
                kind: event.kind,
                type: event.type,
                eclipseMicrodegrees: Self.microdegrees(event.eclipseDegree),
                centrality: event.centrality,
                magnitudeBits: event.magnitude?.bitPattern,
                secondaryMagnitudeBits: event.secondaryMagnitude?.bitPattern
            )
            guard seen.insert(address).inserted else {
                throw PolluxError.ambiguousEclipseIdentity
            }
            let offset = Int64(((event.julianDay.value - storage.supportedStart.value) * 86_400).rounded())
            result.append(PolluxEclipseQuestion(
                address: address,
                handoff: PolluxCivicHandoff(candidateSHA256: candidateSHA256, civicOffsetSeconds: offset)
            ))
        }

        return result.sorted {
            if $0.address.eclipseMicrodegrees != $1.address.eclipseMicrodegrees {
                return $0.address.eclipseMicrodegrees < $1.address.eclipseMicrodegrees
            }
            if $0.address.kind.rawValue != $1.address.kind.rawValue {
                return $0.address.kind.rawValue < $1.address.kind.rawValue
            }
            if $0.address.type.rawValue != $1.address.type.rawValue {
                return $0.address.type.rawValue < $1.address.type.rawValue
            }
            return ($0.address.centrality ?? "") < ($1.address.centrality ?? "")
        }
    }

    private static func microdegrees(_ degrees: Double) -> UInt32 {
        MundaneTimespineStorageImage.microdegrees(degrees)
    }
}
