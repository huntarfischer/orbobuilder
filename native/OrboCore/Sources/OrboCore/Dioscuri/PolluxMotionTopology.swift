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

/// Streaming adjacent-occurrence topology cursor. Full P22 contains nearly 1.8 million
/// adjacency questions, so certification must not materialize them all at once. The cursor
/// walks each stored tract once and advances through its station table monotonically.
struct PolluxMotionTopologyCursor: Sendable {
    private let candidateSHA256: String
    private let bodies: [MundaneTimespineStoredBody]
    private var bodyPosition = 0
    private var occurrencePosition = 1
    private var stationPosition = 0

    init(candidateSHA256: String, storage: MundaneTimespineStorageImage) {
        self.candidateSHA256 = candidateSHA256
        self.bodies = storage.bodies.sorted { $0.body.rawValue < $1.body.rawValue }
    }

    mutating func next() -> PolluxMotionTopologyQuestion? {
        while bodyPosition < bodies.count {
            let body = bodies[bodyPosition]
            guard body.occurrences.count > 1 else {
                advanceBody()
                continue
            }
            guard occurrencePosition < body.occurrences.count else {
                advanceBody()
                continue
            }

            let previous = body.occurrences[occurrencePosition - 1]
            let current = body.occurrences[occurrencePosition]

            while stationPosition < body.stations.count,
                  body.stations[stationPosition].civicOffsetSeconds <= previous.civicOffsetSeconds {
                stationPosition += 1
            }

            var stations: [PolluxStationAddress] = []
            var scan = stationPosition
            while scan < body.stations.count,
                  body.stations[scan].civicOffsetSeconds <= current.civicOffsetSeconds {
                let station = body.stations[scan]
                stations.append(PolluxStationAddress(
                    body: body.body,
                    celestialMicrodegrees: station.celestialMicrodegrees,
                    motionAfter: station.motionAfter
                ))
                scan += 1
            }
            stationPosition = scan
            occurrencePosition += 1

            let address = PolluxMotionTopologyAddress(
                body: body.body,
                from: Self.celestialAddress(storedBody: body, occurrence: previous),
                to: Self.celestialAddress(storedBody: body, occurrence: current),
                fromDirection: previous.sequenceDirection,
                toDirection: current.sequenceDirection,
                stationsBetween: stations
            )
            return PolluxMotionTopologyQuestion(
                address: address,
                handoff: PolluxCivicHandoff(
                    candidateSHA256: candidateSHA256,
                    civicOffsetSeconds: current.civicOffsetSeconds
                )
            )
        }
        return nil
    }

    private mutating func advanceBody() {
        bodyPosition += 1
        occurrencePosition = 1
        stationPosition = 0
    }

    private static func celestialAddress(
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
}

/// Direct second-strike reconstruction. The fresh Pollux first resolves a celestial endpoint to
/// its mortal occurrence; this helper then derives only that occurrence's adjacent topology from
/// the immutable tract. No exhaustive cursor replay is involved.
struct PolluxMotionTopologyDirectLookup {
    static let law = "celestial endpoint -> indexed civic occurrence -> adjacent topology"

    static func reconstruct(
        endpoint: PolluxQuestion,
        storage: MundaneTimespineStorageImage
    ) -> PolluxMotionTopologyQuestion? {
        guard let body = storage.bodies.first(where: { $0.body == endpoint.celestialAddress.body }),
              let currentIndex = occurrenceIndex(
                civicOffsetSeconds: endpoint.handoff.civicOffsetSeconds,
                in: body.occurrences
              ),
              currentIndex > 0 else {
            return nil
        }

        let previous = body.occurrences[currentIndex - 1]
        let current = body.occurrences[currentIndex]
        let currentAddress = celestialAddress(storedBody: body, occurrence: current)
        guard currentAddress == endpoint.celestialAddress else { return nil }

        var stations: [PolluxStationAddress] = []
        var stationIndex = firstStationIndex(
            after: previous.civicOffsetSeconds,
            in: body.stations
        )
        while stationIndex < body.stations.count,
              body.stations[stationIndex].civicOffsetSeconds <= current.civicOffsetSeconds {
            let station = body.stations[stationIndex]
            stations.append(PolluxStationAddress(
                body: body.body,
                celestialMicrodegrees: station.celestialMicrodegrees,
                motionAfter: station.motionAfter
            ))
            stationIndex += 1
        }

        return PolluxMotionTopologyQuestion(
            address: PolluxMotionTopologyAddress(
                body: body.body,
                from: celestialAddress(storedBody: body, occurrence: previous),
                to: currentAddress,
                fromDirection: previous.sequenceDirection,
                toDirection: current.sequenceDirection,
                stationsBetween: stations
            ),
            handoff: endpoint.handoff
        )
    }

    private static func occurrenceIndex(
        civicOffsetSeconds: Int64,
        in occurrences: [MundaneTimespineStoredOccurrence]
    ) -> Int? {
        var lower = 0
        var upper = occurrences.count
        while lower < upper {
            let midpoint = lower + (upper - lower) / 2
            if occurrences[midpoint].civicOffsetSeconds < civicOffsetSeconds {
                lower = midpoint + 1
            } else {
                upper = midpoint
            }
        }
        guard lower < occurrences.count,
              occurrences[lower].civicOffsetSeconds == civicOffsetSeconds else {
            return nil
        }
        return lower
    }

    private static func firstStationIndex(
        after civicOffsetSeconds: Int64,
        in stations: [MundaneTimespineStoredStation]
    ) -> Int {
        var lower = 0
        var upper = stations.count
        while lower < upper {
            let midpoint = lower + (upper - lower) / 2
            if stations[midpoint].civicOffsetSeconds <= civicOffsetSeconds {
                lower = midpoint + 1
            } else {
                upper = midpoint
            }
        }
        return lower
    }

    private static func celestialAddress(
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
}

extension Pollux {
    public static let motionTopologySecondStrikeLookupLaw = PolluxMotionTopologyDirectLookup.law

    func makeMotionTopologyCursor(storage: MundaneTimespineStorageImage) -> PolluxMotionTopologyCursor {
        PolluxMotionTopologyCursor(candidateSHA256: candidateSHA256, storage: storage)
    }

    func motionTopologyQuestionCount(storage: MundaneTimespineStorageImage) -> Int {
        storage.bodies.reduce(0) { $0 + max(0, $1.occurrences.count - 1) }
    }

    /// Reconstruct one disputed adjacency from a celestial endpoint without replaying earlier
    /// topology questions. `ask` remains the celestial-first authority for the endpoint handoff.
    func reconstructMotionTopologyQuestion(
        endingAt endpointAddress: PolluxCelestialAddress,
        storage: MundaneTimespineStorageImage
    ) throws -> PolluxMotionTopologyQuestion? {
        let endpoint = try ask(endpointAddress)
        return PolluxMotionTopologyDirectLookup.reconstruct(endpoint: endpoint, storage: storage)
    }

    /// Retained for focused tests. Production certification consumes the streaming cursor above,
    /// and second strikes use direct celestial reconstruction rather than replaying this cursor.
    func makeMotionTopologyQuestions(storage: MundaneTimespineStorageImage) -> [PolluxMotionTopologyQuestion] {
        var cursor = makeMotionTopologyCursor(storage: storage)
        var questions: [PolluxMotionTopologyQuestion] = []
        questions.reserveCapacity(motionTopologyQuestionCount(storage: storage))
        while let question = cursor.next() {
            questions.append(question)
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
