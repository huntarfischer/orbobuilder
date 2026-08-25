/// Pollux is the celestial resonator. He begins with independent forged celestial matter and
/// discovers its UT. He does not consult OrboSpine Locate and does not depend on Forge storage.
public enum PolluxResonator {
    public static func ask(
        _ challenge: SpineCelestialChallenge,
        from source: any SpineResonanceSource
    ) -> OrboSpineCelestialCoordinate? {
        guard let bodyMatter = source.resonanceBody(challenge.body) else { return nil }
        let matches = occurrences(
            of: challenge.directionalDegree,
            in: bodyMatter
        )
        guard challenge.occurrenceIndex < matches.count else { return nil }
        return matches[challenge.occurrenceIndex]
    }

    static func occurrences(
        of directionalDegree: OrboSpineDirectionalDegree,
        in bodyMatter: SpineResonanceBodyMatter
    ) -> [OrboSpineCelestialCoordinate] {
        let supports = bodyMatter.supports.sorted { $0.julianDay.value < $1.julianDay.value }
        let stationJulianDays = bodyMatter.stations.map(\.julianDay.value).sorted()
        var matches = supports.filter { $0.directionalDegree == directionalDegree }

        if supports.count >= 2 {
            for index in 0..<(supports.count - 1) {
                let lower = supports[index]
                let upper = supports[index + 1]
                guard lower.directionalDegree.motion == directionalDegree.motion,
                      upper.directionalDegree.motion == directionalDegree.motion,
                      !hasStation(
                        between: lower.julianDay,
                        and: upper.julianDay,
                        sortedStationJulianDays: stationJulianDays
                      ) else {
                    continue
                }

                let span = directionalDistance(
                    from: lower.directionalDegree.physicalDegrees,
                    to: upper.directionalDegree.physicalDegrees,
                    motion: directionalDegree.motion
                )
                let target = directionalDistance(
                    from: lower.directionalDegree.physicalDegrees,
                    to: directionalDegree.physicalDegrees,
                    motion: directionalDegree.motion
                )
                guard span > epsilon,
                      target > epsilon,
                      target < span - epsilon else {
                    continue
                }

                let fraction = target / span
                guard let julianDay = JulianDay(
                    lower.julianDay.value
                        + (upper.julianDay.value - lower.julianDay.value) * fraction
                ) else {
                    continue
                }
                matches.append(OrboSpineCelestialCoordinate(
                    body: bodyMatter.body,
                    directionalDegree: directionalDegree,
                    julianDay: julianDay
                ))
            }
        }

        matches.sort { $0.julianDay.value < $1.julianDay.value }
        var deduplicated: [OrboSpineCelestialCoordinate] = []
        deduplicated.reserveCapacity(matches.count)
        for match in matches {
            if let previous = deduplicated.last,
               abs(previous.julianDay.value - match.julianDay.value) <= epsilon {
                continue
            }
            deduplicated.append(match)
        }
        return deduplicated
    }

    /// Stage-2 campaign tests still construct Forge body fixtures directly. The resonance
    /// algorithm remains owned by the source-matter path above.
    static func occurrences(
        of directionalDegree: OrboSpineDirectionalDegree,
        in bodyProduct: SpineForgeBodyProduct
    ) -> [OrboSpineCelestialCoordinate] {
        occurrences(
            of: directionalDegree,
            in: SpineResonanceBodyMatter(bodyProduct)
        )
    }

    public static func ask(
        _ challenge: SpineStationChallenge,
        from source: any SpineResonanceSource
    ) -> OrboSpineCelestialCoordinate? {
        guard let bodyMatter = source.resonanceBody(challenge.body) else { return nil }
        let stations = bodyMatter.stations.sorted { $0.julianDay.value < $1.julianDay.value }
        guard challenge.occurrenceIndex < stations.count else { return nil }
        let station = stations[challenge.occurrenceIndex]
        return OrboSpineCelestialCoordinate(
            body: station.body,
            directionalDegree: station.directionalDegreeAfter,
            julianDay: station.julianDay
        )
    }

    public static func confirm(
        expected: OrboSpineCelestialCoordinate,
        returned: OrboSpineCelestialCoordinate
    ) -> SpineResonanceResult {
        guard expected.body == returned.body,
              expected.julianDay == returned.julianDay,
              expected.directionalDegree.motion == returned.directionalDegree.motion else {
            return .divergent(expected: expected, returned: returned)
        }

        let rawDifference = abs(
            expected.directionalDegree.physicalDegrees
                - returned.directionalDegree.physicalDegrees
        )
        let degreeDifference = min(rawDifference, 360 - rawDifference)

        return degreeDifference <= confirmationEpsilon
            ? .confirmed
            : .divergent(expected: expected, returned: returned)
    }

    private static let epsilon = 1e-10
    private static let confirmationEpsilon = 1e-9

    private static func hasStation(
        between lower: JulianDay,
        and upper: JulianDay,
        sortedStationJulianDays: [Double]
    ) -> Bool {
        let lowerBound = lower.value + epsilon
        let upperBound = upper.value - epsilon
        guard lowerBound < upperBound, !sortedStationJulianDays.isEmpty else { return false }

        var low = 0
        var high = sortedStationJulianDays.count
        while low < high {
            let mid = low + (high - low) / 2
            if sortedStationJulianDays[mid] <= lowerBound {
                low = mid + 1
            } else {
                high = mid
            }
        }

        return low < sortedStationJulianDays.count
            && sortedStationJulianDays[low] < upperBound
    }

    private static func directionalDistance(
        from start: Double,
        to end: Double,
        motion: Motion
    ) -> Double {
        let raw: Double
        switch motion {
        case .direct:
            raw = end - start
        case .retrograde:
            raw = start - end
        }
        var normalized = raw.truncatingRemainder(dividingBy: 360)
        if normalized < 0 { normalized += 360 }
        return normalized
    }
}
