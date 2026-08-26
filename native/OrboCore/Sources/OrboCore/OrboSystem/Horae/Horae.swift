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

    /// Drives UT while keeping one canonical body as the pinned readout grip.
    ///
    /// The cross-section still comes from the proven SEEK path. Horae only add
    /// the control/readout address to that same outward signal; the body's
    /// directional degree is the value already supplied by Locate at this UT.
    public func driveUT(
        to julianDay: JulianDay,
        body: MundaneBody
    ) throws -> HoraeOutput {
        let output = try seek(to: julianDay)
        guard let coordinate = output.celestial.first(where: { $0.body == body }) else {
            throw OrboSpineLocateError.bodyUnavailable(body)
        }

        let address = HoraeAddress(
            body: body,
            directionalDegree: coordinate.directionalDegree,
            julianDay: julianDay
        )
        let controlState = HoraeControlState(
            address: address,
            bodyRole: .pinned,
            directionalDegreeRole: .resolved,
            julianDayRole: .driven
        )

        return HoraeOutput(
            julianDay: output.julianDay,
            celestial: output.celestial,
            terra: output.terra,
            controlState: controlState
        )
    }

    /// Drives one body's directional degree along its forged tract and resolves UT.
    ///
    /// The current UT is only a continuity anchor. If the requested directional
    /// degree occurs more than once on the Bone, Horae choose the occurrence
    /// nearest that anchor. An exact tie is rejected rather than guessed.
    public func driveDirectionalDegree(
        to directionalDegree: OrboSpineDirectionalDegree,
        body: MundaneBody,
        from currentJulianDay: JulianDay
    ) throws -> HoraeOutput {
        _ = try locate.coordinate(of: body, at: currentJulianDay)

        let occurrences = try locate.occurrences(
            of: body,
            at: directionalDegree
        )
        guard !occurrences.isEmpty else {
            throw HoraeControlError.noOccurrence(
                body: body,
                directionalDegree: directionalDegree
            )
        }

        let ranked = occurrences.sorted { lhs, rhs in
            let lhsDistance = abs(lhs.julianDay.value - currentJulianDay.value)
            let rhsDistance = abs(rhs.julianDay.value - currentJulianDay.value)
            if abs(lhsDistance - rhsDistance) <= 1e-10 {
                return lhs.julianDay.value < rhs.julianDay.value
            }
            return lhsDistance < rhsDistance
        }

        if ranked.count > 1 {
            let firstDistance = abs(ranked[0].julianDay.value - currentJulianDay.value)
            let secondDistance = abs(ranked[1].julianDay.value - currentJulianDay.value)
            if abs(firstDistance - secondDistance) <= 1e-10 {
                throw HoraeControlError.ambiguousOccurrence(
                    body: body,
                    directionalDegree: directionalDegree
                )
            }
        }

        let occurrence = ranked[0]
        let output = try seek(to: occurrence.julianDay)
        let controlState = HoraeControlState(
            address: HoraeAddress(
                body: body,
                directionalDegree: occurrence.directionalDegree,
                julianDay: occurrence.julianDay
            ),
            bodyRole: .pinned,
            directionalDegreeRole: .driven,
            julianDayRole: .resolved
        )

        return HoraeOutput(
            julianDay: output.julianDay,
            celestial: output.celestial,
            terra: output.terra,
            controlState: controlState
        )
    }

    /// Uses the current real-world instant only to supply UT, then follows the
    /// exact same output path as SEEK.
    public func live() throws -> HoraeOutput {
        try seek(to: now().julianDay)
    }
}
