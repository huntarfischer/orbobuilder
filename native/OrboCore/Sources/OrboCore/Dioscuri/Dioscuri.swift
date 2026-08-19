import Foundation

public enum DioscuriCertificationPhase: String, CaseIterable, Sendable {
    case bodyOccurrence = "body-occurrence"
    case motionTopology = "motion-topology"
    case station
    case exactRelationship = "exact-relationship"
    case eclipse
}

public enum DioscuriCertificationActivity: String, Hashable, Sendable {
    case phaseProgress = "phase-progress"
    case secondStrikeStarted = "second-strike-started"
    case secondStrikeCompleted = "second-strike-completed"
}

public struct DioscuriCertificationProgress: Hashable, Sendable {
    public let phase: DioscuriCertificationPhase
    public let completed: Int
    public let total: Int
    public let activity: DioscuriCertificationActivity
    public let detail: String?

    public init(
        phase: DioscuriCertificationPhase,
        completed: Int,
        total: Int,
        activity: DioscuriCertificationActivity = .phaseProgress,
        detail: String? = nil
    ) {
        self.phase = phase
        self.completed = completed
        self.total = total
        self.activity = activity
        self.detail = detail
    }
}

/// Dual-resonator integrity gate for one immutable Hephaestus Timespine candidate.
///
/// Pollux always originates the challenge in celestial time. Castor receives only the civic
/// handoff and independently reads the candidate. Pollux confirms the returned celestial state.
/// Dioscuri records the testimony and returns it to Hephaestus; it never seals or repairs.
public struct Dioscuri: Sendable {
    public static let contractVersion: UInt16 = 1
    public static let certificationImplementationVersion: UInt16 = 3
    public static let checkpointQuestionCadence = 10_000
    public static let checkpointLaw = "candidate-bound / whole-question / deterministic-prefix"
    public static let checkpointValidationLaw = DioscuriCheckpointValidator.law
    public static let role = "Timespine integrity gate"
    public static let order = "Pollux -> Castor -> Pollux"
    public static let origin = "celestial"
    public static let oracleRole = "none"
    public static let forgeRole = "none"
    public static let correctionRole = "none"
    public static let averagingRole = "none"
    public static let quantizationPolicy = "explicit / integer-second"
    public static let secondStrikePolicy = "required on divergence"
    public static let secondStrikeVisibilityLaw = "start / finish progress events with phase and question position"
    public static let divergencePolicy = "fail closed"
    public static let verdictTarget = "Hephaestus"
    public static let sealAuthority = "Hephaestus"
    public static let exhaustiveExecutionLaw = "streamed / bounded working set"

    public let candidateSHA256: String

    private let candidate: TimespineCandidate
    private let storage: MundaneTimespineStorageImage
    private let pollux: Pollux
    private let castor: Castor
    private let stationSecondStrikeLookup: PolluxStationDirectLookup
    private let eclipseSecondStrikeLookup: PolluxEclipseDirectLookup

    public init(candidate: TimespineCandidate) throws {
        let decodedStorage = try candidate.artifact.storageImage()
        let decodedPollux = try Pollux(candidate: candidate)
        let decodedCastor = try Castor(candidate: candidate)
        let stationLookup = try decodedPollux.makeStationDirectLookup(storage: decodedStorage)
        let eclipseLookup = try decodedPollux.makeEclipseDirectLookup(storage: decodedStorage)

        self.candidate = candidate
        self.pollux = decodedPollux
        self.castor = decodedCastor
        self.storage = decodedStorage
        self.stationSecondStrikeLookup = stationLookup
        self.eclipseSecondStrikeLookup = eclipseLookup
        self.candidateSHA256 = candidate.identity.sha256
    }

    /// One body/marker/motion pulse. A divergence is struck a second time with fresh twins.
    public func strike(_ question: PolluxQuestion) throws -> DioscuriStrikeReport {
        let firstAnswer = try castor.answer(question.handoff)
        let first = pollux.confirm(question, answer: firstAnswer, storage: storage)
        let second = try secondStrikeIfNeeded(question: question, first: first)
        let divergences = second.map { divergenceEvidence(first: first, second: $0) } ?? []
        return DioscuriStrikeReport(first: first, second: second, divergences: divergences)
    }

    /// Fresh exhaustive certification. This remains the simple API used by existing callers.
    public func certify(
        progress: ((DioscuriCertificationProgress) -> Void)? = nil
    ) throws -> DioscuriVerdict {
        try certify(
            resumingFrom: nil,
            progress: progress,
            checkpointHandler: nil
        )
    }

    /// Exhaustive celestial-first certification with durable, candidate-bound partial testimony.
    /// A checkpoint is emitted only after a complete question, including its second strike when
    /// required. Resume seeks directly to the next deterministic question and never replays prior
    /// Castor reads merely to recover position.
    public func certify(
        resumingFrom checkpoint: DioscuriCertificationCheckpoint?,
        progress: ((DioscuriCertificationProgress) -> Void)? = nil,
        checkpointHandler: ((DioscuriCertificationCheckpoint) throws -> Void)? = nil
    ) throws -> DioscuriVerdict {
        let bodyTotal = pollux.questionCount
        let motionTotal = pollux.motionTopologyQuestionCount(storage: storage)
        let stationQuestions = try pollux.makeStationQuestions(storage: storage)
        let relationshipTotal = storage.relationships.count
        let eclipseQuestions = try pollux.makeEclipseQuestions(storage: storage)
        let totals = DioscuriCertificationOffsets(
            bodyOccurrence: bodyTotal,
            motionTopology: motionTotal,
            station: stationQuestions.count,
            exactRelationship: relationshipTotal,
            eclipse: eclipseQuestions.count
        )

        var completed = DioscuriCertificationOffsets()
        var accumulator = TallyAccumulator()
        var divergences: [DioscuriDivergence] = []

        if let checkpoint {
            try validate(checkpoint: checkpoint, totals: totals)
            completed = checkpoint.completed
            accumulator = try TallyAccumulator(restoring: checkpoint.scopeTallies)
            divergences = checkpoint.divergences
        }

        // Body occurrences / marker fingerprints.
        emit(progress, phase: .bodyOccurrence, completed: completed.bodyOccurrence, total: bodyTotal)
        if completed.bodyOccurrence < bodyTotal {
            guard var bodyCursor = pollux.makeQuestionCursor(startingAt: completed.bodyOccurrence) else {
                throw DioscuriCheckpointError.invalidProgress
            }
            while let question = bodyCursor.next() {
                let firstAnswer = try castor.answer(question.handoff)
                let first = pollux.confirm(question, answer: firstAnswer, storage: storage)
                let second = try performSecondStrikeIfNeeded(
                    question: question,
                    first: first,
                    phase: .bodyOccurrence,
                    questionNumber: completed.bodyOccurrence + 1,
                    total: bodyTotal,
                    progress: progress
                )
                accumulator.record(first.checks)
                if let second {
                    divergences.append(contentsOf: divergenceEvidence(first: first, second: second))
                }
                completed.bodyOccurrence += 1
                emitPeriodic(progress, phase: .bodyOccurrence, completed: completed.bodyOccurrence, total: bodyTotal)
                try checkpointIfNeeded(
                    checkpointHandler,
                    completed: completed,
                    accumulator: accumulator,
                    divergences: divergences,
                    phaseCompleted: completed.bodyOccurrence,
                    phaseTotal: bodyTotal,
                    force: second != nil
                )
            }
        }

        // Adjacent motion topology.
        emit(progress, phase: .motionTopology, completed: completed.motionTopology, total: motionTotal)
        if completed.motionTopology < motionTotal {
            guard var motionCursor = pollux.makeMotionTopologyCursor(
                storage: storage,
                startingAt: completed.motionTopology
            ) else {
                throw DioscuriCheckpointError.invalidProgress
            }
            while let question = motionCursor.next() {
                let firstAnswer = try castor.answer(question.handoff)
                let first = pollux.confirm(question, answer: firstAnswer)
                let second = try performSecondStrikeIfNeeded(
                    question: question,
                    first: first,
                    phase: .motionTopology,
                    questionNumber: completed.motionTopology + 1,
                    total: motionTotal,
                    progress: progress
                )
                accumulator.record(first.checks)
                if let second {
                    divergences.append(contentsOf: divergenceEvidence(first: first, second: second))
                }
                completed.motionTopology += 1
                emitPeriodic(progress, phase: .motionTopology, completed: completed.motionTopology, total: motionTotal)
                try checkpointIfNeeded(
                    checkpointHandler,
                    completed: completed,
                    accumulator: accumulator,
                    divergences: divergences,
                    phaseCompleted: completed.motionTopology,
                    phaseTotal: motionTotal,
                    force: second != nil
                )
            }
        }

        // Stations are small enough to materialize for their deterministic first-pass order.
        // Any second strike resolves the disputed celestial station through the compact direct map.
        emit(progress, phase: .station, completed: completed.station, total: stationQuestions.count)
        if completed.station < stationQuestions.count {
            for index in completed.station..<stationQuestions.count {
                let question = stationQuestions[index]
                let firstAnswer = try castor.answer(question.handoff)
                let first = pollux.confirm(question, answer: firstAnswer, storage: storage)
                let second = try performSecondStrikeIfNeeded(
                    question: question,
                    first: first,
                    phase: .station,
                    questionNumber: index + 1,
                    total: stationQuestions.count,
                    progress: progress
                )
                accumulator.record(first.checks)
                if let second {
                    divergences.append(contentsOf: divergenceEvidence(first: first, second: second))
                }
                completed.station = index + 1
                emitPeriodic(progress, phase: .station, completed: completed.station, total: stationQuestions.count)
                try checkpointIfNeeded(
                    checkpointHandler,
                    completed: completed,
                    accumulator: accumulator,
                    divergences: divergences,
                    phaseCompleted: completed.station,
                    phaseTotal: stationQuestions.count,
                    force: second != nil
                )
            }
        }

        // Exact relationships. Resume reconstructs only the celestial recurrence prefix without
        // Castor reads, then continues at the next untested relationship. Second strikes are direct.
        emit(progress, phase: .exactRelationship, completed: completed.exactRelationship, total: relationshipTotal)
        if completed.exactRelationship < relationshipTotal {
            var relationshipCursor = try pollux.makeRelationshipQuestionCursor(
                storage: storage,
                startingAt: completed.exactRelationship
            )
            var relationshipSecondStrikeLookup: PolluxRelationshipDirectLookup?
            while let question = try relationshipCursor.next() {
                let firstAnswer = try castor.answer(question.handoff)
                let first = pollux.confirm(question, answer: firstAnswer, storage: storage)
                let second: PolluxConfirmation?
                if first.isResonant {
                    second = nil
                } else {
                    emitSecondStrike(
                        progress,
                        phase: .exactRelationship,
                        completed: completed.exactRelationship + 1,
                        total: relationshipTotal,
                        activity: .secondStrikeStarted,
                        first: first
                    )
                    if relationshipSecondStrikeLookup == nil {
                        relationshipSecondStrikeLookup = try pollux.makeRelationshipDirectLookup(storage: storage)
                    }
                    second = try secondStrikeIfNeeded(
                        question: question,
                        first: first,
                        lookup: relationshipSecondStrikeLookup!
                    )
                    emitSecondStrike(
                        progress,
                        phase: .exactRelationship,
                        completed: completed.exactRelationship + 1,
                        total: relationshipTotal,
                        activity: .secondStrikeCompleted,
                        first: first,
                        second: second
                    )
                }
                accumulator.record(first.checks)
                if let second {
                    divergences.append(contentsOf: divergenceEvidence(first: first, second: second))
                }
                completed.exactRelationship += 1
                emitPeriodic(
                    progress,
                    phase: .exactRelationship,
                    completed: completed.exactRelationship,
                    total: relationshipTotal
                )
                try checkpointIfNeeded(
                    checkpointHandler,
                    completed: completed,
                    accumulator: accumulator,
                    divergences: divergences,
                    phaseCompleted: completed.exactRelationship,
                    phaseTotal: relationshipTotal,
                    force: second != nil
                )
            }
        }

        // Eclipses are small and directly indexable on resume and on any second strike.
        emit(progress, phase: .eclipse, completed: completed.eclipse, total: eclipseQuestions.count)
        if completed.eclipse < eclipseQuestions.count {
            for index in completed.eclipse..<eclipseQuestions.count {
                let question = eclipseQuestions[index]
                let firstAnswer = try castor.answer(question.handoff)
                let first = pollux.confirm(question, answer: firstAnswer, storage: storage)
                let second = try performSecondStrikeIfNeeded(
                    question: question,
                    first: first,
                    phase: .eclipse,
                    questionNumber: index + 1,
                    total: eclipseQuestions.count,
                    progress: progress
                )
                accumulator.record(first.checks)
                if let second {
                    divergences.append(contentsOf: divergenceEvidence(first: first, second: second))
                }
                completed.eclipse = index + 1
                emitPeriodic(progress, phase: .eclipse, completed: completed.eclipse, total: eclipseQuestions.count)
                try checkpointIfNeeded(
                    checkpointHandler,
                    completed: completed,
                    accumulator: accumulator,
                    divergences: divergences,
                    phaseCompleted: completed.eclipse,
                    phaseTotal: eclipseQuestions.count,
                    force: second != nil
                )
            }
        }

        let tallies = accumulator.finalized()
        if divergences.isEmpty {
            return .certificate(DioscuriCertificate(
                contractVersion: Self.contractVersion,
                candidateSHA256: candidateSHA256,
                recipeIdentifier: candidate.forgeRecord.recipeIdentifier,
                recipeVersion: candidate.forgeRecord.recipeVersion,
                storageVersion: candidate.forgeRecord.storageVersion,
                scopeTallies: tallies
            ))
        }

        return .rejection(DioscuriRejectionReport(
            contractVersion: Self.contractVersion,
            candidateSHA256: candidateSHA256,
            scopeTallies: tallies,
            divergences: divergences
        ))
    }

    private func performSecondStrikeIfNeeded(
        question: PolluxQuestion,
        first: PolluxConfirmation,
        phase: DioscuriCertificationPhase,
        questionNumber: Int,
        total: Int,
        progress: ((DioscuriCertificationProgress) -> Void)?
    ) throws -> PolluxConfirmation? {
        guard !first.isResonant else { return nil }
        emitSecondStrike(
            progress,
            phase: phase,
            completed: questionNumber,
            total: total,
            activity: .secondStrikeStarted,
            first: first
        )
        let second = try secondStrikeIfNeeded(question: question, first: first)
        emitSecondStrike(
            progress,
            phase: phase,
            completed: questionNumber,
            total: total,
            activity: .secondStrikeCompleted,
            first: first,
            second: second
        )
        return second
    }

    private func performSecondStrikeIfNeeded(
        question: PolluxMotionTopologyQuestion,
        first: PolluxConfirmation,
        phase: DioscuriCertificationPhase,
        questionNumber: Int,
        total: Int,
        progress: ((DioscuriCertificationProgress) -> Void)?
    ) throws -> PolluxConfirmation? {
        guard !first.isResonant else { return nil }
        emitSecondStrike(
            progress,
            phase: phase,
            completed: questionNumber,
            total: total,
            activity: .secondStrikeStarted,
            first: first
        )
        let second = try secondStrikeIfNeeded(question: question, first: first)
        emitSecondStrike(
            progress,
            phase: phase,
            completed: questionNumber,
            total: total,
            activity: .secondStrikeCompleted,
            first: first,
            second: second
        )
        return second
    }

    private func performSecondStrikeIfNeeded(
        question: PolluxStationQuestion,
        first: PolluxConfirmation,
        phase: DioscuriCertificationPhase,
        questionNumber: Int,
        total: Int,
        progress: ((DioscuriCertificationProgress) -> Void)?
    ) throws -> PolluxConfirmation? {
        guard !first.isResonant else { return nil }
        emitSecondStrike(
            progress,
            phase: phase,
            completed: questionNumber,
            total: total,
            activity: .secondStrikeStarted,
            first: first
        )
        let second = try secondStrikeIfNeeded(question: question, first: first)
        emitSecondStrike(
            progress,
            phase: phase,
            completed: questionNumber,
            total: total,
            activity: .secondStrikeCompleted,
            first: first,
            second: second
        )
        return second
    }

    private func performSecondStrikeIfNeeded(
        question: PolluxEclipseQuestion,
        first: PolluxConfirmation,
        phase: DioscuriCertificationPhase,
        questionNumber: Int,
        total: Int,
        progress: ((DioscuriCertificationProgress) -> Void)?
    ) throws -> PolluxConfirmation? {
        guard !first.isResonant else { return nil }
        emitSecondStrike(
            progress,
            phase: phase,
            completed: questionNumber,
            total: total,
            activity: .secondStrikeStarted,
            first: first
        )
        let second = try secondStrikeIfNeeded(question: question, first: first)
        emitSecondStrike(
            progress,
            phase: phase,
            completed: questionNumber,
            total: total,
            activity: .secondStrikeCompleted,
            first: first,
            second: second
        )
        return second
    }

    private func secondStrikeIfNeeded(
        question: PolluxQuestion,
        first: PolluxConfirmation
    ) throws -> PolluxConfirmation? {
        guard !first.isResonant else { return nil }
        let freshPollux = try Pollux(candidate: candidate)
        let freshCastor = try Castor(candidate: candidate)
        let freshQuestion = try freshPollux.ask(question.celestialAddress)
        return freshPollux.confirm(
            freshQuestion,
            answer: try freshCastor.answer(freshQuestion.handoff),
            storage: storage
        )
    }

    private func secondStrikeIfNeeded(
        question: PolluxMotionTopologyQuestion,
        first: PolluxConfirmation
    ) throws -> PolluxConfirmation? {
        guard !first.isResonant else { return nil }
        let freshPollux = try Pollux(candidate: candidate)
        let freshCastor = try Castor(candidate: candidate)
        guard let freshQuestion = try freshPollux.reconstructMotionTopologyQuestion(
            endingAt: question.address.to,
            storage: storage
        ), freshQuestion.address == question.address else {
            return nondeterministicFallback(first)
        }
        return freshPollux.confirm(
            freshQuestion,
            answer: try freshCastor.answer(freshQuestion.handoff)
        )
    }

    private func secondStrikeIfNeeded(
        question: PolluxStationQuestion,
        first: PolluxConfirmation
    ) throws -> PolluxConfirmation? {
        guard !first.isResonant else { return nil }
        let freshPollux = try Pollux(candidate: candidate)
        let freshCastor = try Castor(candidate: candidate)
        guard let freshQuestion = freshPollux.reconstructStationQuestion(
            question.address,
            using: stationSecondStrikeLookup
        ), freshQuestion.address == question.address else {
            return nondeterministicFallback(first)
        }
        return freshPollux.confirm(
            freshQuestion,
            answer: try freshCastor.answer(freshQuestion.handoff),
            storage: storage
        )
    }

    private func secondStrikeIfNeeded(
        question: PolluxRelationshipQuestion,
        first: PolluxConfirmation,
        lookup: PolluxRelationshipDirectLookup
    ) throws -> PolluxConfirmation? {
        guard !first.isResonant else { return nil }
        let freshPollux = try Pollux(candidate: candidate)
        let freshCastor = try Castor(candidate: candidate)
        guard let freshQuestion = freshPollux.reconstructRelationshipQuestion(
            question.address,
            using: lookup
        ), freshQuestion.address == question.address else {
            return nondeterministicFallback(first)
        }
        return freshPollux.confirm(
            freshQuestion,
            answer: try freshCastor.answer(freshQuestion.handoff),
            storage: storage
        )
    }

    private func secondStrikeIfNeeded(
        question: PolluxEclipseQuestion,
        first: PolluxConfirmation
    ) throws -> PolluxConfirmation? {
        guard !first.isResonant else { return nil }
        let freshPollux = try Pollux(candidate: candidate)
        let freshCastor = try Castor(candidate: candidate)
        guard let freshQuestion = freshPollux.reconstructEclipseQuestion(
            question.address,
            using: eclipseSecondStrikeLookup
        ), freshQuestion.address == question.address else {
            return nondeterministicFallback(first)
        }
        return freshPollux.confirm(
            freshQuestion,
            answer: try freshCastor.answer(freshQuestion.handoff),
            storage: storage
        )
    }

    private func validate(
        checkpoint: DioscuriCertificationCheckpoint,
        totals: DioscuriCertificationOffsets
    ) throws {
        guard checkpoint.checkpointFormatVersion == DioscuriCertificationCheckpoint.formatVersion else {
            throw DioscuriCheckpointError.unsupportedFormat(checkpoint.checkpointFormatVersion)
        }
        guard checkpoint.candidateSHA256 == candidate.identity.sha256 else {
            throw DioscuriCheckpointError.candidateMismatch
        }
        guard checkpoint.recipeIdentifier == candidate.forgeRecord.recipeIdentifier,
              checkpoint.recipeVersion == candidate.forgeRecord.recipeVersion else {
            throw DioscuriCheckpointError.recipeMismatch
        }
        guard checkpoint.resonanceContract == candidate.forgeRecord.resonanceContract else {
            throw DioscuriCheckpointError.resonanceContractMismatch
        }
        guard checkpoint.dioscuriContractVersion == Self.contractVersion else {
            throw DioscuriCheckpointError.dioscuriContractMismatch
        }
        guard checkpoint.certificationImplementationVersion == Self.certificationImplementationVersion else {
            throw DioscuriCheckpointError.implementationMismatch
        }
        guard checkpoint.storageVersion == candidate.forgeRecord.storageVersion else {
            throw DioscuriCheckpointError.storageVersionMismatch
        }
        guard isValidPrefix(checkpoint.completed, totals: totals) else {
            throw DioscuriCheckpointError.invalidProgress
        }
        _ = try TallyAccumulator(restoring: checkpoint.scopeTallies)
        guard checkpoint.divergences.allSatisfy({ $0.candidateSHA256 == candidate.identity.sha256 }) else {
            throw DioscuriCheckpointError.invalidDivergenceBinding
        }
        try DioscuriCheckpointValidator.validate(checkpoint: checkpoint, storage: storage)
    }

    private func isValidPrefix(
        _ completed: DioscuriCertificationOffsets,
        totals: DioscuriCertificationOffsets
    ) -> Bool {
        let values = [
            completed.bodyOccurrence,
            completed.motionTopology,
            completed.station,
            completed.exactRelationship,
            completed.eclipse,
        ]
        let limits = [
            totals.bodyOccurrence,
            totals.motionTopology,
            totals.station,
            totals.exactRelationship,
            totals.eclipse,
        ]

        var encounteredIncomplete = false
        for index in values.indices {
            let value = values[index]
            let total = limits[index]
            guard (0...total).contains(value) else { return false }
            if encounteredIncomplete {
                guard value == 0 else { return false }
            } else if value < total {
                encounteredIncomplete = true
            }
        }
        return true
    }

    private func checkpointIfNeeded(
        _ handler: ((DioscuriCertificationCheckpoint) throws -> Void)?,
        completed: DioscuriCertificationOffsets,
        accumulator: TallyAccumulator,
        divergences: [DioscuriDivergence],
        phaseCompleted: Int,
        phaseTotal: Int,
        force: Bool
    ) throws {
        guard let handler else { return }
        guard force
                || phaseCompleted == phaseTotal
                || (phaseCompleted > 0 && phaseCompleted % Self.checkpointQuestionCadence == 0) else {
            return
        }
        try handler(DioscuriCertificationCheckpoint(
            candidate: candidate,
            certificationImplementationVersion: Self.certificationImplementationVersion,
            completed: completed,
            scopeTallies: accumulator.finalized(),
            divergences: divergences
        ))
    }

    private func emitPeriodic(
        _ progress: ((DioscuriCertificationProgress) -> Void)?,
        phase: DioscuriCertificationPhase,
        completed: Int,
        total: Int
    ) {
        if completed == total || completed % 10_000 == 0 {
            emit(progress, phase: phase, completed: completed, total: total)
        }
    }

    private func emitSecondStrike(
        _ progress: ((DioscuriCertificationProgress) -> Void)?,
        phase: DioscuriCertificationPhase,
        completed: Int,
        total: Int,
        activity: DioscuriCertificationActivity,
        first: PolluxConfirmation,
        second: PolluxConfirmation? = nil
    ) {
        let subject = first.checks.first(where: { $0.outcome == .divergence })?.subject
            ?? "divergent celestial question"
        let detail: String
        switch activity {
        case .secondStrikeStarted:
            detail = subject
        case .secondStrikeCompleted:
            if let second, second.isResonant {
                detail = "not reproduced / \(subject)"
            } else if second != nil {
                detail = "reproduced divergence / \(subject)"
            } else {
                detail = "second strike unavailable / \(subject)"
            }
        case .phaseProgress:
            detail = subject
        }
        emit(
            progress,
            phase: phase,
            completed: completed,
            total: total,
            activity: activity,
            detail: detail
        )
    }

    private func emit(
        _ progress: ((DioscuriCertificationProgress) -> Void)?,
        phase: DioscuriCertificationPhase,
        completed: Int,
        total: Int,
        activity: DioscuriCertificationActivity = .phaseProgress,
        detail: String? = nil
    ) {
        progress?(DioscuriCertificationProgress(
            phase: phase,
            completed: completed,
            total: total,
            activity: activity,
            detail: detail
        ))
    }

    private func nondeterministicFallback(_ first: PolluxConfirmation) -> PolluxConfirmation {
        PolluxConfirmation(
            candidateSHA256: first.candidateSHA256,
            civicOffsetSeconds: first.civicOffsetSeconds,
            checks: first.checks.map {
                DioscuriInvariantCheck(
                    scope: $0.scope,
                    outcome: .resonance,
                    kind: .nondeterministicResonance,
                    subject: $0.subject,
                    expected: $0.expected,
                    observed: "second strike could not reconstruct the same celestial question"
                )
            }
        )
    }

    private func divergenceEvidence(
        first: PolluxConfirmation,
        second: PolluxConfirmation
    ) -> [DioscuriDivergence] {
        let firstFailures = first.checks.filter { $0.outcome == .divergence }
        return firstFailures.map { failure in
            let secondMatch = second.checks.first {
                $0.scope == failure.scope && $0.kind == failure.kind && $0.subject == failure.subject
            }
            let deterministic = secondMatch?.outcome == .divergence
                && secondMatch?.expected == failure.expected
                && secondMatch?.observed == failure.observed
            return DioscuriDivergence(
                candidateSHA256: candidateSHA256,
                scope: failure.scope,
                kind: deterministic ? failure.kind : .nondeterministicResonance,
                civicOffsetSeconds: first.civicOffsetSeconds,
                subject: failure.subject,
                expected: failure.expected,
                firstObserved: failure.observed,
                secondObserved: secondMatch?.observed ?? "second strike did not reproduce the invariant",
                deterministic: deterministic
            )
        }
    }
}

private struct TallyAccumulator {
    private struct MutableTally {
        var questions = 0
        var resonant = 0
        var quantized = 0
        var divergent = 0
    }

    private var values: [DioscuriScope: MutableTally] = [:]

    init() {}

    init(restoring tallies: [DioscuriScopeTally]) throws {
        guard tallies.count == DioscuriScope.allCases.count else {
            throw DioscuriCheckpointError.invalidTallies
        }
        var seen = Set<DioscuriScope>()
        for tally in tallies {
            guard seen.insert(tally.scope).inserted,
                  tally.questions >= 0,
                  tally.resonant >= 0,
                  tally.quantizedCoincidences >= 0,
                  tally.divergent >= 0,
                  tally.questions == tally.resonant + tally.quantizedCoincidences + tally.divergent else {
                throw DioscuriCheckpointError.invalidTallies
            }
            values[tally.scope] = MutableTally(
                questions: tally.questions,
                resonant: tally.resonant,
                quantized: tally.quantizedCoincidences,
                divergent: tally.divergent
            )
        }
    }

    mutating func record(_ checks: [DioscuriInvariantCheck]) {
        for check in checks {
            var tally = values[check.scope] ?? MutableTally()
            tally.questions += 1
            switch check.outcome {
            case .resonance: tally.resonant += 1
            case .quantizedCoincidence: tally.quantized += 1
            case .divergence: tally.divergent += 1
            }
            values[check.scope] = tally
        }
    }

    func finalized() -> [DioscuriScopeTally] {
        DioscuriScope.allCases.map { scope in
            let tally = values[scope] ?? MutableTally()
            return DioscuriScopeTally(
                scope: scope,
                questions: tally.questions,
                resonant: tally.resonant,
                quantizedCoincidences: tally.quantized,
                divergent: tally.divergent
            )
        }
    }
}
