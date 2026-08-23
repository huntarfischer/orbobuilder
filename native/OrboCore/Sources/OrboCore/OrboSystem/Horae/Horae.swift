import Foundation

/// Presentation-neutral temporal adapter posted at OrboSpine Door I: Locate.
///
/// Horae do not calculate or refine Timespine truth. They ask Locate for the
/// canonical cross-section at one supplied UT and carry that signal outward.
public struct Horae: Sendable {
    private let locate: OrboSpineLocate
    private let now: @Sendable () -> AbsoluteInstant

    public init(
        locate: OrboSpineLocate,
        now: @escaping @Sendable () -> AbsoluteInstant = {
            AbsoluteInstant(unixSecondsSince1970: Date().timeIntervalSince1970)!
        }
    ) {
        self.locate = locate
        self.now = now
    }

    /// Explicitly selects one UT on the OrboSpine Bone and returns the complete
    /// canonical celestial + Terra cross-section exposed by Locate at that level.
    public func seek(to julianDay: JulianDay) throws -> HoraeOutput {
        let celestial = try OrboSpineContract.canonicalBodies.map { body in
            try locate.coordinate(of: body, at: julianDay)
        }
        let terra = try locate.terra(at: julianDay)

        return HoraeOutput(
            julianDay: julianDay,
            celestial: celestial,
            terra: terra
        )
    }

    /// Uses the current real-world instant only to supply UT, then follows the
    /// exact same output path as SEEK.
    public func live() throws -> HoraeOutput {
        try seek(to: now().julianDay)
    }
}
