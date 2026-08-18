import Foundation

/// Castor's blind civic observation of one Timespine instant.
///
/// This answer contains only what the runtime Reader independently finds at the handed-off
/// civic occurrence. It deliberately carries no Pollux celestial address, marker fingerprint,
/// expected direction, or pass/fail judgment.
public struct CastorAnswer: Sendable {
    public let candidateSHA256: String
    public let civicOffsetSeconds: Int64
    public let julianDay: JulianDay
    public let states: [MundaneTimespineBodyState]

    init(
        candidateSHA256: String,
        civicOffsetSeconds: Int64,
        julianDay: JulianDay,
        states: [MundaneTimespineBodyState]
    ) {
        self.candidateSHA256 = candidateSHA256
        self.civicOffsetSeconds = civicOffsetSeconds
        self.julianDay = julianDay
        self.states = states
    }

    public subscript(_ body: MundaneBody) -> MundaneTimespineBodyState? {
        states.first { $0.body == body }
    }
}
