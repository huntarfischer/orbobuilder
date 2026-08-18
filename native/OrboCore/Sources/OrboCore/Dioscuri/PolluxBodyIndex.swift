import Foundation

struct PolluxBodyIndex: Sendable {
    let body: MundaneBody
    let ticksPerDegree: Int
    let markerBodies: [MundaneBody]
    let occurrences: [MundaneTimespineStoredOccurrence]
    let occurrenceIndicesByTick: [[Int]]

    init(storedBody: MundaneTimespineStoredBody) throws {
        body = storedBody.body
        ticksPerDegree = storedBody.ticksPerDegree
        markerBodies = storedBody.markerBodies
        occurrences = storedBody.occurrences

        var buckets = Array(repeating: [Int](), count: 360 * storedBody.ticksPerDegree)
        for index in storedBody.occurrences.indices {
            let tick = storedBody.occurrences[index].celestialTick
            guard buckets.indices.contains(tick) else {
                throw PolluxError.candidateContractMismatch
            }
            buckets[tick].append(index)
        }

        for tick in buckets.indices {
            buckets[tick].sort { lhsIndex, rhsIndex in
                let lhs = storedBody.occurrences[lhsIndex]
                let rhs = storedBody.occurrences[rhsIndex]
                if lhs.markerWholeDegrees == rhs.markerWholeDegrees {
                    return lhs.civicOffsetSeconds < rhs.civicOffsetSeconds
                }
                return Self.markersLess(lhs.markerWholeDegrees, rhs.markerWholeDegrees)
            }

            if buckets[tick].count > 1 {
                for position in 1..<buckets[tick].count {
                    let previous = storedBody.occurrences[buckets[tick][position - 1]]
                    let current = storedBody.occurrences[buckets[tick][position]]
                    if previous.markerWholeDegrees == current.markerWholeDegrees {
                        throw PolluxError.ambiguousCelestialIdentity(
                            body: storedBody.body,
                            celestialTick: tick
                        )
                    }
                }
            }
        }

        occurrenceIndicesByTick = buckets
    }

    func occurrenceIndex(for address: PolluxCelestialAddress) throws -> Int {
        guard address.body == body,
              address.ticksPerDegree == ticksPerDegree,
              address.markerFingerprint.map(\.body) == markerBodies,
              occurrenceIndicesByTick.indices.contains(address.celestialTick) else {
            throw PolluxError.celestialAddressShapeMismatch(body: address.body)
        }

        let target = address.markerFingerprint.map(\.wholeDegree)
        let bucket = occurrenceIndicesByTick[address.celestialTick]
        var lower = 0
        var upper = bucket.count

        while lower < upper {
            let midpoint = lower + (upper - lower) / 2
            let index = bucket[midpoint]
            let markers = occurrences[index].markerWholeDegrees
            if markers == target { return index }
            if Self.markersLess(markers, target) {
                lower = midpoint + 1
            } else {
                upper = midpoint
            }
        }

        throw PolluxError.celestialAddressNotFound(
            body: address.body,
            celestialTick: address.celestialTick
        )
    }

    func question(
        occurrenceIndex: Int,
        candidateSHA256: String
    ) -> PolluxQuestion {
        let occurrence = occurrences[occurrenceIndex]
        let fingerprint = zip(markerBodies, occurrence.markerWholeDegrees).map { body, degree in
            PolluxMarkerCell(body: body, wholeDegree: degree)!
        }
        let address = PolluxCelestialAddress(
            body: body,
            celestialTick: occurrence.celestialTick,
            ticksPerDegree: ticksPerDegree,
            markerFingerprint: fingerprint
        )!
        return PolluxQuestion(
            celestialAddress: address,
            expectedSequenceDirection: occurrence.sequenceDirection,
            handoff: PolluxCivicHandoff(
                candidateSHA256: candidateSHA256,
                civicOffsetSeconds: occurrence.civicOffsetSeconds
            )
        )
    }

    private static func markersLess(_ lhs: [UInt16], _ rhs: [UInt16]) -> Bool {
        let shared = min(lhs.count, rhs.count)
        for index in 0..<shared {
            if lhs[index] != rhs[index] { return lhs[index] < rhs[index] }
        }
        return lhs.count < rhs.count
    }
}
