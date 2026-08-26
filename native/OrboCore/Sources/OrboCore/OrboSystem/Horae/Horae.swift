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

    /// Drives UT while body and directional degree remain pinned.
    ///
    /// UT may land only on a real occurrence of that exact body/state pair.
    /// The requested UT is the navigation grip; Horae choose the valid occurrence
    /// nearest it and reject an exact tie rather than guess.
    public func driveUT(
        to julianDay: JulianDay,
        body: MundaneBody,
        directionalDegree: OrboSpineDirectionalDegree
    ) throws -> HoraeOutput {
        _ = try locate.coordinate(of: body, at: julianDay)
        let occurrence = try nearestOccurrence(
            of: body,
            at: directionalDegree,
            to: julianDay
        )
        let output = try seek(to: occurrence.julianDay)
        let controlState = HoraeControlState(
            address: HoraeAddress(
                body: body,
                directionalDegree: occurrence.directionalDegree,
                julianDay: occurrence.julianDay
            ),
            bodyRole: .pinned,
            directionalDegreeRole: .pinned,
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
        let occurrence = try nearestOccurrence(
            of: body,
            at: directionalDegree,
            to: currentJulianDay
        )
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

    /// Drives the body grip while UT remains pinned to one horizontal cross-section.
    /// The selected body's directional degree is resolved directly from that
    /// already-forged cross-section.
    public func driveBody(
        to body: MundaneBody,
        at julianDay: JulianDay
    ) throws -> HoraeOutput {
        let output = try seek(to: julianDay)
        guard let coordinate = output.celestial.first(where: { $0.body == body }) else {
            throw OrboSpineLocateError.bodyUnavailable(body)
        }

        let controlState = HoraeControlState(
            address: HoraeAddress(
                body: body,
                directionalDegree: coordinate.directionalDegree,
                julianDay: julianDay
            ),
            bodyRole: .driven,
            directionalDegreeRole: .resolved,
            julianDayRole: .pinned
        )

        return HoraeOutput(
            julianDay: output.julianDay,
            celestial: output.celestial,
            terra: output.terra,
            controlState: controlState
        )
    }

    /// Drives the body grip while directional degree remains pinned and UT resolves.
    ///
    /// The current UT is only a continuity anchor. Changing bodies changes the
    /// occurrence set being navigated; Horae choose the selected body's real
    /// occurrence nearest that anchor and never fabricate a UT.
    public func driveBody(
        to body: MundaneBody,
        at directionalDegree: OrboSpineDirectionalDegree,
        from currentJulianDay: JulianDay
    ) throws -> HoraeOutput {
        _ = try locate.coordinate(of: body, at: currentJulianDay)
        let occurrence = try nearestOccurrence(
            of: body,
            at: directionalDegree,
            to: currentJulianDay
        )
        let output = try seek(to: occurrence.julianDay)
        let controlState = HoraeControlState(
            address: HoraeAddress(
                body: body,
                directionalDegree: occurrence.directionalDegree,
                julianDay: occurrence.julianDay
            ),
            bodyRole: .driven,
            directionalDegreeRole: .pinned,
            julianDayRole: .resolved
        )

        return HoraeOutput(
            julianDay: output.julianDay,
            celestial: output.celestial,
            terra: output.terra,
            controlState: controlState
        )
    }

    /// Drives the body grip under exact directional-degree and UT constraints.
    /// The selected body is valid only if its forged coordinate at the pinned UT
    /// satisfies the pinned directional state.
    public func driveBody(
        to body: MundaneBody,
        matching directionalDegree: OrboSpineDirectionalDegree,
        at julianDay: JulianDay
    ) throws -> HoraeOutput {
        let coordinate = try locate.coordinate(of: body, at: julianDay)
        guard coordinate.directionalDegree.motion == directionalDegree.motion,
              abs(
                coordinate.directionalDegree.physicalDegrees
                    - directionalDegree.physicalDegrees
              ) <= 1e-10 else {
            throw HoraeControlError.constraintUnsatisfied(
                body: body,
                directionalDegree: directionalDegree,
                julianDay: julianDay
            )
        }

        let output = try seek(to: julianDay)
        let controlState = HoraeControlState(
            address: HoraeAddress(
                body: body,
                directionalDegree: coordinate.directionalDegree,
                julianDay: julianDay
            ),
            bodyRole: .driven,
            directionalDegreeRole: .pinned,
            julianDayRole: .pinned
        )

        return HoraeOutput(
            julianDay: output.julianDay,
            celestial: output.celestial,
            terra: output.terra,
            controlState: controlState
        )
    }

    /// Presentation-neutral ingress for a visualization owner such as Iris.
    /// Each intent is routed to one already-proven Horae control path and returns
    /// the same single HoraeOutput cable.
    public func respond(to intent: HoraeControlIntent) throws -> HoraeOutput {
        switch intent {
        case let .driveUT(julianDay, body):
            return try driveUT(to: julianDay, body: body)
        case let .driveConstrainedUT(julianDay, body, directionalDegree):
            return try driveUT(
                to: julianDay,
                body: body,
                directionalDegree: directionalDegree
            )
        case let .driveDirectionalDegree(directionalDegree, body, currentJulianDay):
            return try driveDirectionalDegree(
                to: directionalDegree,
                body: body,
                from: currentJulianDay
            )
        case let .driveBody(body, julianDay):
            return try driveBody(to: body, at: julianDay)
        case let .driveBodyAtDegree(body, directionalDegree, currentJulianDay):
            return try driveBody(
                to: body,
                at: directionalDegree,
                from: currentJulianDay
            )
        case let .driveConstrainedBody(body, directionalDegree, julianDay):
            return try driveBody(
                to: body,
                matching: directionalDegree,
                at: julianDay
            )
        }
    }

    /// Uses the current real-world instant only to supply UT, then follows the
    /// exact same output path as SEEK.
    public func live() throws -> HoraeOutput {
        try seek(to: now().julianDay)
    }

    private func nearestOccurrence(
        of body: MundaneBody,
        at directionalDegree: OrboSpineDirectionalDegree,
        to anchor: JulianDay
    ) throws -> OrboSpineOccurrence {
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
            let lhsDistance = abs(lhs.julianDay.value - anchor.value)
            let rhsDistance = abs(rhs.julianDay.value - anchor.value)
            if abs(lhsDistance - rhsDistance) <= 1e-10 {
                return lhs.julianDay.value < rhs.julianDay.value
            }
            return lhsDistance < rhsDistance
        }

        if ranked.count > 1 {
            let firstDistance = abs(ranked[0].julianDay.value - anchor.value)
            let secondDistance = abs(ranked[1].julianDay.value - anchor.value)
            if abs(firstDistance - secondDistance) <= 1e-10 {
                throw HoraeControlError.ambiguousOccurrence(
                    body: body,
                    directionalDegree: directionalDegree
                )
            }
        }

        return ranked[0]
    }
}
