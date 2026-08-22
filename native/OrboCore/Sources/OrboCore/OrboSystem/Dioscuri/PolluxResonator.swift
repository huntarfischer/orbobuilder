/// Pollux is the celestial resonator. He begins with celestial truth and discovers its UT
/// from the finished forged celestial product. He does not consult OrboSpine Locate.
public enum PolluxResonator {
    public static func ask(
        _ challenge: SpineCelestialChallenge,
        from celestialProduct: SpineForgeProduct
    ) -> OrboSpineCelestialCoordinate? {
        guard let bodyProduct = celestialProduct.body(challenge.body) else { return nil }

        let matches = bodyProduct.supports
            .filter { $0.directionalDegree == challenge.directionalDegree }
            .sorted { $0.julianDay.value < $1.julianDay.value }

        guard challenge.occurrenceIndex < matches.count else { return nil }
        return matches[challenge.occurrenceIndex]
    }

    public static func confirm(
        expected: OrboSpineCelestialCoordinate,
        returned: OrboSpineCelestialCoordinate
    ) -> SpineResonanceResult {
        expected == returned
            ? .confirmed
            : .divergent(expected: expected, returned: returned)
    }
}
