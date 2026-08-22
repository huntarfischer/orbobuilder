import Foundation

extension Pollux {
    func confirm(
        _ question: PolluxQuestion,
        answer: CastorAnswer,
        storage: MundaneTimespineStorageImage
    ) -> PolluxConfirmation {
        var checks: [DioscuriInvariantCheck] = []
        let address = question.celestialAddress

        guard answer.candidateSHA256 == question.handoff.candidateSHA256,
              answer.civicOffsetSeconds == question.handoff.civicOffsetSeconds else {
            checks.append(DioscuriInvariantCheck(
                scope: .bodyOccurrence,
                outcome: .divergence,
                kind: .candidateIdentity,
                subject: address.body.displayName,
                expected: "candidate \(question.handoff.candidateSHA256) / offset \(question.handoff.civicOffsetSeconds)",
                observed: "candidate \(answer.candidateSHA256) / offset \(answer.civicOffsetSeconds)"
            ))
            return PolluxConfirmation(
                candidateSHA256: candidateSHA256,
                civicOffsetSeconds: question.handoff.civicOffsetSeconds,
                checks: checks
            )
        }

        guard let focal = answer[address.body] else {
            checks.append(DioscuriInvariantCheck(
                scope: .bodyOccurrence,
                outcome: .divergence,
                kind: .celestialIdentity,
                subject: address.body.displayName,
                expected: celestialDescription(address),
                observed: "body unavailable"
            ))
            return PolluxConfirmation(
                candidateSHA256: candidateSHA256,
                civicOffsetSeconds: question.handoff.civicOffsetSeconds,
                checks: checks
            )
        }

        let focalTick = canonicalTick(
            focal.celestialTimeDegrees,
            ticksPerDegree: address.ticksPerDegree
        )
        checks.append(DioscuriInvariantCheck(
            scope: .bodyOccurrence,
            outcome: focalTick == address.celestialTick ? .resonance : .divergence,
            kind: .celestialIdentity,
            subject: address.body.displayName,
            expected: celestialDescription(address),
            observed: "tick \(focalTick) / \(String(format: "%.9f", focal.celestialTimeDegrees)) degrees / \(focal.source.rawValue)"
        ))

        checks.append(DioscuriInvariantCheck(
            scope: .motion,
            outcome: focal.motion == question.expectedSequenceDirection.motion ? .resonance : .divergence,
            kind: .motion,
            subject: address.body.displayName,
            expected: question.expectedSequenceDirection.motion.rawValue,
            observed: focal.motion.rawValue
        ))

        for marker in address.markerFingerprint {
            guard let markerState = answer[marker.body] else {
                checks.append(DioscuriInvariantCheck(
                    scope: .marker,
                    outcome: .divergence,
                    kind: .marker,
                    subject: "\(address.body.displayName) / \(marker.body.displayName)",
                    expected: "whole-degree cell \(marker.wholeDegree)",
                    observed: "marker body unavailable"
                ))
                continue
            }

            let observedCell = wholeDegreeCell(markerState.celestialTimeDegrees)
            let outcome: DioscuriInvariantOutcome
            if observedCell == marker.wholeDegree {
                outcome = .resonance
            } else if isQuantizedCellTransition(
                body: marker.body,
                expectedCell: Int(marker.wholeDegree),
                observedCell: Int(observedCell),
                civicOffsetSeconds: question.handoff.civicOffsetSeconds,
                storage: storage
            ) {
                outcome = .quantizedCoincidence
            } else {
                outcome = .divergence
            }

            checks.append(DioscuriInvariantCheck(
                scope: .marker,
                outcome: outcome,
                kind: .marker,
                subject: "\(address.body.displayName) / \(marker.body.displayName)",
                expected: "whole-degree cell \(marker.wholeDegree)",
                observed: "cell \(observedCell) / \(String(format: "%.9f", markerState.celestialTimeDegrees)) degrees / \(markerState.source.rawValue)"
            ))
        }

        return PolluxConfirmation(
            candidateSHA256: candidateSHA256,
            civicOffsetSeconds: question.handoff.civicOffsetSeconds,
            checks: checks
        )
    }

    func confirm(
        _ question: PolluxStationQuestion,
        answer: CastorAnswer,
        storage: MundaneTimespineStorageImage
    ) -> PolluxConfirmation {
        let address = question.address
        guard let state = answer[address.body] else {
            return confirmation(
                offset: question.handoff.civicOffsetSeconds,
                check: DioscuriInvariantCheck(
                    scope: .motion,
                    outcome: .divergence,
                    kind: .motion,
                    subject: "\(address.body.displayName) station",
                    expected: stationDescription(address),
                    observed: "body unavailable"
                )
            )
        }

        let observedMicrodegrees = MundaneTimespineStorageImage.microdegrees(state.celestialTimeDegrees)
        let isExact = observedMicrodegrees == address.celestialMicrodegrees
            && state.motion == address.motionAfter
            && state.isStation
            && state.source == .station

        return confirmation(
            offset: question.handoff.civicOffsetSeconds,
            check: DioscuriInvariantCheck(
                scope: .motion,
                outcome: isExact ? .resonance : .divergence,
                kind: .motion,
                subject: "\(address.body.displayName) station",
                expected: stationDescription(address),
                observed: "\(observedMicrodegrees) microdegrees / \(state.motion.rawValue) / station \(state.isStation) / \(state.source.rawValue)"
            )
        )
    }

    func confirm(
        _ question: PolluxRelationshipQuestion,
        answer: CastorAnswer,
        storage: MundaneTimespineStorageImage
    ) -> PolluxConfirmation {
        let address = question.address
        let expectedB = expectedBodyBMicrodegrees(
            bodyAMicrodegrees: address.bodyAMicrodegrees,
            mark: address.mark,
            orientation: address.orientation
        )

        guard expectedB == address.bodyBMicrodegrees else {
            return confirmation(
                offset: question.handoff.civicOffsetSeconds,
                check: DioscuriInvariantCheck(
                    scope: .exactRelationship,
                    outcome: .divergence,
                    kind: .relationshipGeometry,
                    subject: "\(address.bodyA.displayName) / \(address.bodyB.displayName) / \(address.mark.rawValue)",
                    expected: "body B \(expectedB) microdegrees from exact Ring geometry",
                    observed: "body B \(address.bodyBMicrodegrees) microdegrees"
                )
            )
        }

        guard let stateA = answer[address.bodyA], let stateB = answer[address.bodyB] else {
            return confirmation(
                offset: question.handoff.civicOffsetSeconds,
                check: DioscuriInvariantCheck(
                    scope: .exactRelationship,
                    outcome: .divergence,
                    kind: .relationshipOccurrence,
                    subject: "\(address.bodyA.displayName) / \(address.bodyB.displayName) / \(address.mark.rawValue)",
                    expected: "both bodies available at handed-off civic occurrence",
                    observed: "one or both bodies unavailable"
                )
            )
        }

        let outcomeA = exactCelestialOutcome(
            body: address.bodyA,
            expectedMicrodegrees: address.bodyAMicrodegrees,
            observedDegrees: stateA.celestialTimeDegrees,
            civicOffsetSeconds: question.handoff.civicOffsetSeconds,
            storage: storage
        )
        let outcomeB = exactCelestialOutcome(
            body: address.bodyB,
            expectedMicrodegrees: address.bodyBMicrodegrees,
            observedDegrees: stateB.celestialTimeDegrees,
            civicOffsetSeconds: question.handoff.civicOffsetSeconds,
            storage: storage
        )
        let outcome = combined(outcomeA, outcomeB)

        return confirmation(
            offset: question.handoff.civicOffsetSeconds,
            check: DioscuriInvariantCheck(
                scope: .exactRelationship,
                outcome: outcome,
                kind: .relationshipOccurrence,
                subject: "\(address.bodyA.displayName) / \(address.bodyB.displayName) / \(address.mark.rawValue)",
                expected: "A \(address.bodyAMicrodegrees) / B \(address.bodyBMicrodegrees) microdegree celestial cells",
                observed: "A \(String(format: "%.9f", stateA.celestialTimeDegrees)) / B \(String(format: "%.9f", stateB.celestialTimeDegrees)) degrees"
            )
        )
    }

    func confirm(
        _ question: PolluxEclipseQuestion,
        answer: CastorAnswer,
        storage: MundaneTimespineStorageImage
    ) -> PolluxConfirmation {
        let address = question.address
        guard let sun = answer[.sun], let moon = answer[.moon] else {
            return confirmation(
                offset: question.handoff.civicOffsetSeconds,
                check: DioscuriInvariantCheck(
                    scope: .eclipse,
                    outcome: .divergence,
                    kind: .eclipseOccurrence,
                    subject: "\(address.kind.rawValue) \(address.type.rawValue) eclipse",
                    expected: "Sun and Moon available",
                    observed: "Sun or Moon unavailable"
                )
            )
        }

        let moonExpected = address.eclipseMicrodegrees
        let sunExpected: UInt32
        switch address.kind {
        case .solar:
            sunExpected = address.eclipseMicrodegrees
        case .lunar:
            sunExpected = UInt32(
                (UInt64(address.eclipseMicrodegrees) + 180 * MundaneTimespineStorageFormat.microdegreesPerDegree)
                    % MundaneTimespineStorageFormat.circleMicrodegrees
            )
        }

        let sunOutcome = exactCelestialOutcome(
            body: .sun,
            expectedMicrodegrees: sunExpected,
            observedDegrees: sun.celestialTimeDegrees,
            civicOffsetSeconds: question.handoff.civicOffsetSeconds,
            storage: storage
        )
        let moonOutcome = exactCelestialOutcome(
            body: .moon,
            expectedMicrodegrees: moonExpected,
            observedDegrees: moon.celestialTimeDegrees,
            civicOffsetSeconds: question.handoff.civicOffsetSeconds,
            storage: storage
        )
        let outcome = combined(sunOutcome, moonOutcome)

        return confirmation(
            offset: question.handoff.civicOffsetSeconds,
            check: DioscuriInvariantCheck(
                scope: .eclipse,
                outcome: outcome,
                kind: .eclipseGeometry,
                subject: "\(address.kind.rawValue) \(address.type.rawValue) eclipse",
                expected: "Sun \(sunExpected) / Moon \(moonExpected) microdegree celestial cells",
                observed: "Sun \(String(format: "%.9f", sun.celestialTimeDegrees)) / Moon \(String(format: "%.9f", moon.celestialTimeDegrees)) degrees"
            )
        )
    }

    private func confirmation(offset: Int64, check: DioscuriInvariantCheck) -> PolluxConfirmation {
        PolluxConfirmation(
            candidateSHA256: candidateSHA256,
            civicOffsetSeconds: offset,
            checks: [check]
        )
    }

    private func celestialDescription(_ address: PolluxCelestialAddress) -> String {
        "tick \(address.celestialTick) / \(String(format: "%.9f", address.celestialDegrees)) degrees"
    }

    private func stationDescription(_ address: PolluxStationAddress) -> String {
        "\(address.celestialMicrodegrees) microdegrees / motion after \(address.motionAfter.rawValue) / station true"
    }

    private func canonicalTick(_ degrees: Double, ticksPerDegree: Int) -> Int {
        let circle = 360 * ticksPerDegree
        let raw = Int((degrees * Double(ticksPerDegree)).rounded())
        return ((raw % circle) + circle) % circle
    }

    private func wholeDegreeCell(_ degrees: Double) -> UInt16 {
        var normalized = degrees.truncatingRemainder(dividingBy: 360)
        if normalized < 0 { normalized += 360 }
        return UInt16(Int(floor(normalized)) % 360)
    }

    /// Exact relationship/eclipses carry an exact celestial coordinate, not merely a marker cell.
    /// If Reader lands in the adjacent lattice cell at the same stored second, admit quantization
    /// only when linear travel between the stored lattice crossings places that exact coordinate
    /// in the same rounded civic second. This prevents a distant exact coordinate from borrowing
    /// a boundary crossing as false evidence.
    private func exactCelestialOutcome(
        body: MundaneBody,
        expectedMicrodegrees: UInt32,
        observedDegrees: Double,
        civicOffsetSeconds: Int64,
        storage: MundaneTimespineStorageImage
    ) -> DioscuriInvariantOutcome {
        guard let stored = storage.bodies.first(where: { $0.body == body }) else { return .divergence }
        let ticks = stored.ticksPerDegree
        let circle = 360 * ticks
        let expectedCoordinate = Double(expectedMicrodegrees)
            * Double(ticks)
            / Double(MundaneTimespineStorageFormat.microdegreesPerDegree)
        let observedCoordinate = normalizedDegrees(observedDegrees) * Double(ticks)
        let expectedCell = Int(floor(expectedCoordinate)) % circle
        let observedCell = Int(floor(observedCoordinate)) % circle

        if expectedCell == observedCell { return .resonance }
        if isExactQuantizedTickTransition(
            storedBody: stored,
            expectedCoordinate: expectedCoordinate,
            expectedCell: expectedCell,
            observedCell: observedCell,
            civicOffsetSeconds: civicOffsetSeconds
        ) {
            return .quantizedCoincidence
        }
        return .divergence
    }

    private func isQuantizedCellTransition(
        body: MundaneBody,
        expectedCell: Int,
        observedCell: Int,
        civicOffsetSeconds: Int64,
        storage: MundaneTimespineStorageImage
    ) -> Bool {
        guard let stored = storage.bodies.first(where: { $0.body == body }) else { return false }
        let forward = (observedCell - expectedCell + 360) % 360
        let backward = (expectedCell - observedCell + 360) % 360
        guard forward == 1 || backward == 1 else { return false }

        let boundaryDegree = forward == 1 ? observedCell : expectedCell
        let boundaryTick = (boundaryDegree % 360) * stored.ticksPerDegree
        return stored.occurrences.contains {
            $0.celestialTick == boundaryTick && $0.civicOffsetSeconds == civicOffsetSeconds
        }
    }

    private func isExactQuantizedTickTransition(
        storedBody: MundaneTimespineStoredBody,
        expectedCoordinate: Double,
        expectedCell: Int,
        observedCell: Int,
        civicOffsetSeconds: Int64
    ) -> Bool {
        let circle = 360 * storedBody.ticksPerDegree
        let forward = (observedCell - expectedCell + circle) % circle
        let backward = (expectedCell - observedCell + circle) % circle
        guard forward == 1 || backward == 1 else { return false }

        let boundaryTick = forward == 1 ? observedCell : expectedCell
        guard let boundaryIndex = storedBody.occurrences.firstIndex(where: {
            $0.celestialTick == boundaryTick && $0.civicOffsetSeconds == civicOffsetSeconds
        }) else { return false }

        let boundary = storedBody.occurrences[boundaryIndex]
        let direction = boundary.sequenceDirection
        let boundaryCoordinate = Double(boundaryTick)
        let distanceBefore = motionDistance(
            from: expectedCoordinate,
            to: boundaryCoordinate,
            direction: direction,
            circle: Double(circle)
        )
        let distanceAfter = motionDistance(
            from: boundaryCoordinate,
            to: expectedCoordinate,
            direction: direction,
            circle: Double(circle)
        )
        let epsilon = 1e-12

        if distanceBefore <= 1 + epsilon,
           let previous = adjacentOccurrence(
               to: boundary,
               before: true,
               in: storedBody,
               circle: circle
           ) {
            let span = Double(boundary.civicOffsetSeconds - previous.civicOffsetSeconds)
            guard span > 0 else { return false }
            let estimatedOffset = Double(boundary.civicOffsetSeconds) - distanceBefore * span
            return Int64(estimatedOffset.rounded()) == civicOffsetSeconds
        }

        if distanceAfter <= 1 + epsilon,
           let next = adjacentOccurrence(
               to: boundary,
               before: false,
               in: storedBody,
               circle: circle
           ) {
            let span = Double(next.civicOffsetSeconds - boundary.civicOffsetSeconds)
            guard span > 0 else { return false }
            let estimatedOffset = Double(boundary.civicOffsetSeconds) + distanceAfter * span
            return Int64(estimatedOffset.rounded()) == civicOffsetSeconds
        }

        return false
    }

    private func adjacentOccurrence(
        to boundary: MundaneTimespineStoredOccurrence,
        before: Bool,
        in storedBody: MundaneTimespineStoredBody,
        circle: Int
    ) -> MundaneTimespineStoredOccurrence? {
        let step = boundary.sequenceDirection == .increasing ? 1 : -1
        let targetTick = ((boundary.celestialTick + (before ? -step : step)) % circle + circle) % circle

        if before {
            return storedBody.occurrences
                .filter {
                    $0.sequenceDirection == boundary.sequenceDirection
                        && $0.celestialTick == targetTick
                        && $0.civicOffsetSeconds < boundary.civicOffsetSeconds
                }
                .max { $0.civicOffsetSeconds < $1.civicOffsetSeconds }
        }

        return storedBody.occurrences
            .filter {
                $0.sequenceDirection == boundary.sequenceDirection
                    && $0.celestialTick == targetTick
                    && $0.civicOffsetSeconds > boundary.civicOffsetSeconds
            }
            .min { $0.civicOffsetSeconds < $1.civicOffsetSeconds }
    }

    private func motionDistance(
        from start: Double,
        to end: Double,
        direction: MundaneCelestialSequenceDirection,
        circle: Double
    ) -> Double {
        let raw: Double
        switch direction {
        case .increasing:
            raw = end - start
        case .decreasing:
            raw = start - end
        }
        let result = raw.truncatingRemainder(dividingBy: circle)
        return result >= 0 ? result : result + circle
    }

    private func normalizedDegrees(_ value: Double) -> Double {
        let result = value.truncatingRemainder(dividingBy: 360)
        return result >= 0 ? result : result + 360
    }

    private func expectedBodyBMicrodegrees(
        bodyAMicrodegrees: UInt32,
        mark: RingMark,
        orientation: MundaneTimespineRelationshipOrientation
    ) -> UInt32 {
        let circle = Int64(MundaneTimespineStorageFormat.circleMicrodegrees)
        let a = Int64(bodyAMicrodegrees)
        let delta = Int64(mark.rawValue) * Int64(MundaneTimespineStorageFormat.microdegreesPerDegree)
        let raw: Int64
        switch orientation {
        case .sameDegree:
            raw = a
        case .oppositeDegree:
            raw = a + 180 * Int64(MundaneTimespineStorageFormat.microdegreesPerDegree)
        case .bodyAAhead:
            raw = a - delta
        case .bodyBAhead:
            raw = a + delta
        }
        return UInt32((raw % circle + circle) % circle)
    }

    private func combined(
        _ first: DioscuriInvariantOutcome,
        _ second: DioscuriInvariantOutcome
    ) -> DioscuriInvariantOutcome {
        if first == .divergence || second == .divergence { return .divergence }
        if first == .quantizedCoincidence || second == .quantizedCoincidence {
            return .quantizedCoincidence
        }
        return .resonance
    }
}
