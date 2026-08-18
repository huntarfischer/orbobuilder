import Foundation

struct PolluxMotionTopologyAddress: Hashable, Sendable {
    let body: MundaneBody
    let from: PolluxCelestialAddress
    let to: PolluxCelestialAddress
    let fromDirection: MundaneCelestialSequenceDirection
    let toDirection: MundaneCelestialSequenceDirection
    let stationsBetween: [PolluxStationAddress]
}

struct PolluxMotionTopologyQuestion: Hashable, Sendable {
    let address: PolluxMotionTopologyAddress
    let handoff: PolluxCivicHandoff
}

extension Pollux {
    func makeMotionTopologyQuestions(storage: MundaneTimespineStorageImage) -> [PolluxMotionTopologyQuestion] {
        var questions: [PolluxMotionTopologyQuestion] = []

        for body in storage.bodies {
            guard body.occurrences.count > 1 else { continue }
            for index in 1..<body.occurrences.count {
                let previous = body.occurrences[index - 1]
                let current = body.occurrences[index]
                let stations = body.stations
                    .filter {
                        $0.civicOffsetSeconds > previous.civicOffsetSeconds
                            && $0.civicOffsetSeconds <= current.civicOffsetSeconds
                    }
                    .map {
                        PolluxStationAddress(
                            body: body.body,
                            celestialMicrodegrees: $0.celestialMicrodegrees,
                            motionAfter: $0.motionAfter
                        )
                    }
                let address = PolluxMotionTopologyAddress(
                    body: body.body,
                    from: celestialAddress(storedBody: body, occurrence: previous),
                    to: celestialAddress(storedBody: body, occurrence: current),
                    fromDirection: previous.sequenceDirection,
                    toDirection: current.sequenceDirection,
                    stationsBetween: stations
                )
                questions.append(PolluxMotionTopologyQuestion(
                    address: address,
                    handoff: PolluxCivicHandoff(
                        candidateSHA256: candidateSHA256,
                        civicOffsetSeconds: current.civicOffsetSeconds
                    )
                ))
            }
        }

        return questions.sorted {
            if $0.address.body.rawValue != $1.address.body.rawValue {
                return $0.address.body.rawValue < $1.address.body.rawValue
            }
            if $0.address.from.celestialTick != $1.address.from.celestialTick {
                return $0.address.from.celestialTick < $1.address.from.celestialTick
            }
            if $0.address.to.celestialTick != $1.address.to.celestialTick {
                return $0.address.to.celestialTick < $1.address.to.celestialTick
            }
            return markerKey($0.address.from) < markerKey($1.address.from)
        }
    }

    func confirm(
        _ question: PolluxMotionTopologyQuestion,
        answer: CastorAnswer
    ) -> PolluxConfirmation {
        let address = question.address
        let circle = 360 * address.from.ticksPerDegree
        let directStep = (address.from.celestialTick + 1) % circle
        let retrogradeStep = (address.from.celestialTick - 1 + circle) % circle
        let changedDirection = address.fromDirection != address.toDirection

        let structural: Bool
        if !changedDirection {
            structural = address.stationsBetween.isEmpty
                && address.to.celestialTick == (address.toDirection == .increasing ? directStep : retrogradeStep)
        } else {
            let lastStationMatches = address.stationsBetween.last?.motionAfter == address.toDirection.motion
            let stepAfterTurn = address.toDirection == .increasing ? directStep : retrogradeStep
            structural = !address.stationsBetween.isEmpty
                && lastStationMatches
                && (address.to.celestialTick == address.from.celestialTick
                    || address.to.celestialTick == stepAfterTurn)
        }

        let castorState = answer[address.body]
        let castorTick = castorState.map {
            canonicalTick($0.celestialTimeDegrees, ticksPerDegree: address.to.ticksPerDegree)
        }
        let castorAgrees = castorTick == address.to.celestialTick
            && castorState?.motion == address.toDirection.motion
        let outcome: DioscuriInvariantOutcome = structural && castorAgrees ? .resonance : .divergence

        let stationText = address.stationsBetween.isEmpty
            ? "none"
            : address.stationsBetween.map { "\($0.celestialMicrodegrees):\($0.motionAfter.rawValue)" }.joined(separator: ",")
        let check = DioscuriInvariantCheck(
            scope: .motion,
            outcome: outcome,
            kind: .motion,
            subject: "\(address.body.displayName) topology \(address.from.celestialTick)->\(address.to.celestialTick)",
            expected: "\(address.fromDirection.motion.rawValue)->\(address.toDirection.motion.rawValue) / stations \(stationText)",
            observed: "Castor tick \(castorTick.map(String.init) ?? "missing") / motion \(castorState?.motion.rawValue ?? "missing") / structural \(structural)"
        )
        return PolluxConfirmation(
            candidateSHA256: candidateSHA256,
            civicOffsetSeconds: question.handoff.civicOffsetSeconds,
            checks: [check]
        )
    }

    private func celestialAddress(
        storedBody: MundaneTimespineStoredBody,
        occurrence: MundaneTimespineStoredOccurrence
    ) -> PolluxCelestialAddress {
        let markers = zip(storedBody.markerBodies, occurrence.markerWholeDegrees).map {
            PolluxMarkerCell(body: $0.0, wholeDegree: $0.1)!
        }
        return PolluxCelestialAddress(
            body: storedBody.body,
            celestialTick: occurrence.celestialTick,
            ticksPerDegree: storedBody.ticksPerDegree,
            markerFingerprint: markers
        )!
    }

    private func markerKey(_ address: PolluxCelestialAddress) -> String {
        address.markerFingerprint
            .map { "\($0.body.rawValue):\($0.wholeDegree)" }
            .joined(separator: "|")
    }

    private func canonicalTick(_ degrees: Double, ticksPerDegree: Int) -> Int {
        let circle = 360 * ticksPerDegree
        let raw = Int((degrees * Double(ticksPerDegree)).rounded())
        return ((raw % circle) + circle) % circle
    }
}
