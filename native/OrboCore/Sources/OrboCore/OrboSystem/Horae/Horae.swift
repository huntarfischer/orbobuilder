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

    /// Continuous UT envelope available to consumer controls.
    /// OrboSpine owns the boundaries; Horae expose only their values.
    public var controlDomain: HoraeControlDomain {
        HoraeControlDomain(
            start: locate.bone.start,
            endExclusive: locate.bone.end
        )
    }

    /// Every real UT occurrence for one exact body/state pair on the Bone.
    /// An empty array is valid availability information, not a navigation error.
    public func occurrenceUTs(
        of body: MundaneBody,
        at directionalDegree: OrboSpineDirectionalDegree
    ) throws -> [JulianDay] {
        try locate.occurrences(
            of: body,
            at: directionalDegree
        ).map(\.julianDay)
    }

    /// Canonical bodies occupying one exact directional state at one exact UT.
    /// No match is represented by an empty array. An outside-Bone UT remains an
    /// OrboSpine Locate error rather than being clamped or interpreted by Horae.
    public func matchingBodies(
        at directionalDegree: OrboSpineDirectionalDegree,
        on julianDay: JulianDay
    ) throws -> [MundaneBody] {
        try OrboSpineContract.canonicalBodies.filter { body in
            let coordinate = try locate.coordinate(of: body, at: julianDay)
            return Self.directionalDegreeMatches(
                coordinate.directionalDegree,
                directionalDegree
            )
        }
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

    /// Applies one consumer-supplied UT displacement, then follows SEEK.
    ///
    /// Horae retain no current UT and own no playback rate. The consumer supplies
    /// both the current UT and the requested offset on every action.
    public func shiftUT(
        from currentJulianDay: JulianDay,
        by offset: HoraeUTOffset
    ) throws -> HoraeOutput {
        guard let target = JulianDay(
            currentJulianDay.value + offset.julianDays
        ) else {
            throw OrboSpineLocateError.outsideBone
        }
        return try seek(to: target)
    }

    /// Drives UT while keeping one canonical body as the pinned readout grip.
    public func driveUT(
        to julianDay: JulianDay,
        body: MundaneBody
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
        return try outputForPinnedBodyAndDegree(
            body: body,
            occurrence: occurrence
        )
    }

    /// Drives one body's directional degree along its forged tract and resolves UT.
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
    public func driveBody(
        to body: MundaneBody,
        matching directionalDegree: OrboSpineDirectionalDegree,
        at julianDay: JulianDay
    ) throws -> HoraeOutput {
        let coordinate = try locate.coordinate(of: body, at: julianDay)
        guard Self.directionalDegreeMatches(
            coordinate.directionalDegree,
            directionalDegree
        ) else {
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

    /// Moves one step through the ordered occurrence set for a pinned body/state.
    /// The anchor may be on or between occurrences. The chosen UT is always
    /// strictly before or after the anchor, and navigation never wraps the Bone.
    public func navigateOccurrence(
        of body: MundaneBody,
        at directionalDegree: OrboSpineDirectionalDegree,
        from currentJulianDay: JulianDay,
        direction: HoraeOccurrenceDirection
    ) throws -> HoraeOutput {
        _ = try locate.coordinate(of: body, at: currentJulianDay)
        let occurrence = try adjacentOccurrence(
            of: body,
            at: directionalDegree,
            from: currentJulianDay,
            direction: direction
        )
        return try outputForPinnedBodyAndDegree(
            body: body,
            occurrence: occurrence
        )
    }

    /// Presentation-neutral ingress for a visualization owner such as Iris.
    public func respond(to intent: HoraeControlIntent) throws -> HoraeOutput {
        switch intent {
        case let .seekUT(julianDay):
            return try seek(to: julianDay)
        case let .shiftUT(currentJulianDay, offset):
            return try shiftUT(
                from: currentJulianDay,
                by: offset
            )
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
        case let .navigateOccurrence(body, directionalDegree, currentJulianDay, direction):
            return try navigateOccurrence(
                of: body,
                at: directionalDegree,
                from: currentJulianDay,
                direction: direction
            )
        }
    }

    /// Uses the current real-world instant only to supply UT, then follows SEEK.
    public func live() throws -> HoraeOutput {
        try seek(to: now().julianDay)
    }

    private func nearestOccurrence(
        of body: MundaneBody,
        at directionalDegree: OrboSpineDirectionalDegree,
        to anchor: JulianDay
    ) throws -> OrboSpineOccurrence {
        let occurrences = try occurrenceSet(
            of: body,
            at: directionalDegree
        )

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

    private func adjacentOccurrence(
        of body: MundaneBody,
        at directionalDegree: OrboSpineDirectionalDegree,
        from anchor: JulianDay,
        direction: HoraeOccurrenceDirection
    ) throws -> OrboSpineOccurrence {
        let occurrences = try occurrenceSet(
            of: body,
            at: directionalDegree
        ).sorted { $0.julianDay.value < $1.julianDay.value }

        let chosen: OrboSpineOccurrence?
        switch direction {
        case .next:
            chosen = occurrences.first {
                $0.julianDay.value > anchor.value + 1e-10
            }
        case .previous:
            chosen = occurrences.last {
                $0.julianDay.value < anchor.value - 1e-10
            }
        }

        guard let chosen else {
            throw HoraeControlError.noOccurrenceInDirection(
                body: body,
                directionalDegree: directionalDegree,
                from: anchor,
                direction: direction
            )
        }
        return chosen
    }

    private func occurrenceSet(
        of body: MundaneBody,
        at directionalDegree: OrboSpineDirectionalDegree
    ) throws -> [OrboSpineOccurrence] {
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
        return occurrences
    }

    private func outputForPinnedBodyAndDegree(
        body: MundaneBody,
        occurrence: OrboSpineOccurrence
    ) throws -> HoraeOutput {
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

    private static func directionalDegreeMatches(
        _ lhs: OrboSpineDirectionalDegree,
        _ rhs: OrboSpineDirectionalDegree
    ) -> Bool {
        lhs.motion == rhs.motion
            && abs(lhs.physicalDegrees - rhs.physicalDegrees) <= 1e-10
    }
}
