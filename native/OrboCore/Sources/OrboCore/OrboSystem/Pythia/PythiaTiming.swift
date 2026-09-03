public extension Pythia {
    /// Timing starts with a real return to a selected celestial degree. Chronos resolves
    /// its civic occurrences through Horae. Advanced timing techniques remain distinct.
    static func returns(body: MundaneBody, at degree: OrboSpineDirectionalDegree, after moment: JulianDay, using horae: Horae) throws -> ChronosAnswer {
        let result = try Chronos.resolveBodyState(body: body, directionalDegree: degree, using: horae)
        guard case let .resolved(answer) = result else { return ChronosAnswer(hits: []) }
        return ChronosAnswer(hits: Array(answer.hits.filter { $0.address.start.value > moment.value + 1.0 / 86400 }.prefix(20)))
    }
}
