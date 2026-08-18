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

extension PolluxError {
    static func ambiguousStation(_ body: MundaneBody, _ microdegrees: UInt32) -> PolluxError {
        .candidateContractMismatch
    }

    static func ambiguousRelationship() -> PolluxError {
        .candidateContractMismatch
    }

    static func ambiguousEclipse() -> PolluxError {
        .candidateContractMismatch
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
                    throw PolluxError.ambiguousStation(body.body, station.celestialMicrodegrees)
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

    func makeRelationshipQuestions(storage: MundaneTimespineStorageImage) throws -> [PolluxRelationshipQuestion] {
        var seen = Set<PolluxRelationshipAddress>()
        var result: [PolluxRelationshipQuestion] = []
        result.reserveCapacity(storage.relationships.count)

        for event in storage.relationships {
            let address = PolluxRelationshipAddress(
                bodyA: event.bodyA,
                bodyB: event.bodyB,
                mark: event.mark,
                orientation: event.orientation,
                bodyAMicrodegrees: Self.microdegrees(event.bodyACelestialTimeDegrees),
                bodyBMicrodegrees: Self.microdegrees(event.bodyBCelestialTimeDegrees)
            )
            guard seen.insert(address).inserted else {
                throw PolluxError.ambiguousRelationship()
            }
            let offset = Int64(((event.julianDay.value - storage.supportedStart.value) * 86_400).rounded())
            result.append(PolluxRelationshipQuestion(
                address: address,
                handoff: PolluxCivicHandoff(candidateSHA256: candidateSHA256, civicOffsetSeconds: offset)
            ))
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
                throw PolluxError.ambiguousEclipse()
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
