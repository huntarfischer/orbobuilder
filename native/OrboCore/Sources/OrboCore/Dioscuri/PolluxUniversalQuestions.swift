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

/// Streaming relationship cursor. It retains only the celestial identity set required to reject
/// ambiguity; it does not duplicate all 770k P22 questions in another array during certification.
struct PolluxRelationshipQuestionCursor: Sendable {
    private let candidateSHA256: String
    private let supportedStart: JulianDay
    private let relationships: [MundaneTimespineRelationshipEvent]
    private var position = 0
    private var seen = Set<PolluxRelationshipAddress>()

    init(candidateSHA256: String, storage: MundaneTimespineStorageImage) {
        self.candidateSHA256 = candidateSHA256
        self.supportedStart = storage.supportedStart
        self.relationships = storage.relationships
        self.seen.reserveCapacity(storage.relationships.count)
    }

    mutating func next() throws -> PolluxRelationshipQuestion? {
        guard position < relationships.count else { return nil }
        let event = relationships[position]
        position += 1
        let address = PolluxRelationshipAddress(
            bodyA: event.bodyA,
            bodyB: event.bodyB,
            mark: event.mark,
            orientation: event.orientation,
            bodyAMicrodegrees: MundaneTimespineStorageImage.microdegrees(event.bodyACelestialTimeDegrees),
            bodyBMicrodegrees: MundaneTimespineStorageImage.microdegrees(event.bodyBCelestialTimeDegrees)
        )
        guard seen.insert(address).inserted else {
            throw PolluxError.ambiguousRelationshipIdentity
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
}

extension Pollux {
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

    /// Retained for focused tests and second-strike reconstruction. Full certification consumes
    /// the streaming cursor above instead of retaining a second copy of every relationship.
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
            if $0.address.mark.rawValue != $1.address.mark.rawValue {
                return $0.address.mark.rawValue < $1.address.mark.rawValue
            }
            return $0.address.orientation.rawValue < $1.address.orientation.rawValue
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
