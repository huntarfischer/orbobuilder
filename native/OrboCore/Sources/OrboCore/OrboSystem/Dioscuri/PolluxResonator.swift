/// Pollux is the celestial resonator. He begins with celestial truth and discovers its UT
/// from the finished forged celestial product. He does not consult OrboSpine Locate.
public enum PolluxResonator {
    public static func ask(
        _ challenge: SpineCelestialChallenge,
        from celestialProduct: SpineForgeProduct
    ) -> OrboSpineCelestialCoordinate? {
        guard let bodyProduct = celestialProduct.body(challenge.body) else { return nil }

        let supports = bodyProduct.supports.sorted { $0.julianDay.value < $1.julianDay.value }
        var matches = supports.filter { $0.directionalDegree == challenge.directionalDegree }

        if supports.count >= 2 {
            for index in 0..<(supports.count - 1) {
                let lower = supports[index]
                let upper = supports[index + 1]
                guard lower.directionalDegree.motion == challenge.directionalDegree.motion,
                      upper.directionalDegree.motion == challenge.directionalDegree.motion,
                      !hasStation(
                        between: lower.julianDay,
                        and: upper.julianDay,
                        stations: bodyProduct.stations
                      ) else {
                    continue
                }

                let span = directionalDistance(
                    from: lower.directionalDegree.physicalDegrees,
                    to: upper.directionalDegree.physicalDegrees,
                    motion: challenge.directionalDegree.motion
                )
                let target = directionalDistance(
                    from: lower.directionalDegree.physicalDegrees,
                    to: challenge.directionalDegree.physicalDegrees,
                    motion: challenge.directionalDegree.motion
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
                    body: challenge.body,
                    directionalDegree: challenge.directionalDegree,
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

        guard challenge.occurrenceIndex < deduplicated.count else { return nil }
        return deduplicated[challenge.occurrenceIndex]
    }

    public static func ask(
        _ challenge: SpineStationChallenge,
        from celestialProduct: SpineForgeProduct
    ) -> OrboSpineCelestialCoordinate? {
        guard let bodyProduct = celestialProduct.body(challenge.body) else { return nil }
        let stations = bodyProduct.stations.sorted { $0.julianDay.value < $1.julianDay.value }
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
        expected == returned
            ? .confirmed
            : .divergent(expected: expected, returned: returned)
    }

    private static let epsilon = 1e-10

    private static func hasStation(
        between lower: JulianDay,
        and upper: JulianDay,
        stations: [OrboSpineStation]
    ) -> Bool {
        stations.contains {
            $0.julianDay.value > lower.value + epsilon
                && $0.julianDay.value < upper.value - epsilon
        }
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
