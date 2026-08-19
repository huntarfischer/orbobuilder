import Foundation

public enum DioscuriCertificationPhase: String, CaseIterable, Sendable {
    case bodyOccurrence = "body-occurrence"
    case motionTopology = "motion-topology"
    case station
    case exactRelationship = "exact-relationship"
    case eclipse
}

public struct DioscuriCertificationProgress: Hashable, Sendable {
    public let phase: DioscuriCertificationPhase
    public let completed: Int
    public let total: Int

    public init(phase: DioscuriCertificationPhase, completed: Int, total: Int) {
        self.phase = phase
        self.completed = completed
        self.total = total
    }
}

/// Dual-resonator integrity gate for one immutable Hephaestus Timespine candidate.
///
/// Pollux always originates the challenge in celestial time. Castor receives only the civic
/// handoff and independently reads the candidate. Pollux confirms the returned celestial state.
/// Dioscuri records the testimony and returns it to Hephaestus; it never seals or repairs.
public struct Dioscuri: Sendable {
    public static let contractVersion: UInt16 = 1
    public static let role = "Timespine integrity gate"
    public static let order = "Pollux -> Castor -> Pollux"
    public static let origin = "celestial"
    public static let oracleRole = "none"
    public static let forgeRole = "none"
    public static let correctionRole = "none"
    public static let averagingRole = "none"
    public static let quantizationPolicy = "explicit / integer-second"
    public static let secondStrikePolicy = "required on divergence"
    public static let divergencePolicy = "fail closed"
    public static let verdictTarget = "Hephaestus"
    public static let sealAuthority = "Hephaestus"
    public static let exhaustiveExecutionLaw = "streamed / bounded working set"

    public let candidateSHA256: String

    private let candidate: TimespineCandidate
    private let storage: MundaneTimespineStorageImage
    private let pollux: Pollux
    private let castor: Castor

    public init(candidate: TimespineCandidate) throws {
        self.candidate = candidate
        self.pollux = try Pollux(candidate: candidate)
        self.castor = try Castor(candidate: candidate)
        self.storage = try candidate.artifact.storageImage()
        self.candidateSHA256 = candidate.identity.sha256
    }

    /// One body/marker/motion pulse. A divergence is struck a second time with fresh twins.
    public func strike(_ question: PolluxQuestion) throws -> DioscuriStrikeReport {
        let firstAnswer = try castor.answer(question.handoff)
        let first = pollux.confirm(question, answer: firstAnswer, storage: storage)
        guard !first.isResonant else {
            return DioscuriStrikeReport(first: first, second: nil, divergences: [])
        }

        let freshPollux = try Pollux(candidate: candidate)
        let freshCastor = try Castor(candidate: candidate)
        let freshQuestion = try freshPollux.ask(question.celestialAddress)
        let secondAnswer = try freshCastor.answer(freshQuestion.handoff)
        let second = freshPollux.confirm(freshQuestion, answer: secondAnswer, storage: storage)
        let divergences = divergenceEvidence(first: first, second: second)
        return DioscuriStrikeReport(first: first, second: second, divergences: divergences)
    }

    /// Exhaustive celestial-first certification of the scopes implemented by the current
    /// Timespine resonance dialect. Large scopes stream their questions instead of creating a
    /// second full P22-sized question array. Certification continues after divergence so
    /// Hephaestus receives the complete wound map.
    public func certify(
        progress: ((DioscuriCertificationProgress) -> Void)? = nil
    ) throws -> DioscuriVerdict {
        var accumulator = TallyAccumulator()
        var divergences: [DioscuriDivergence] = []

        let bodyTotal = pollux.questionCount
        emit(progress, phase: .bodyOccurrence, completed: 0, total: bodyTotal)
        var bodyCompleted = 0
        var bodyCursor = pollux.makeQuestionCursor()
        while let question = bodyCursor.next() {
            let report = try strike(question)
            accumulator.record(report.first.checks)
            divergences.append(contentsOf: report.divergences)
            bodyCompleted += 1
            emitPeriodic(progress, phase: .bodyOccurrence, completed: bodyCompleted, total: bodyTotal)
        }

        let motionTotal = pollux.motionTopologyQuestionCount(storage: storage)
        emit(progress, phase: .motionTopology, completed: 0, total: motionTotal)
        var motionCompleted = 0
        var motionCursor = pollux.makeMotionTopologyCursor(storage: storage)
        while let question = motionCursor.next() {
            let firstAnswer = try castor.answer(question.handoff)
            let first = pollux.confirm(question, answer: firstAnswer)
            let second = try secondStrikeIfNeeded(question: question, first: first)
            accumulator.record(first.checks)
            if let second {
                divergences.append(contentsOf: divergenceEvidence(first: first, second: second))
            }
            motionCompleted += 1
            emitPeriodic(progress, phase: .motionTopology, completed: motionCompleted, total: motionTotal)
        }

        let stationQuestions = try pollux.makeStationQuestions(storage: storage)
        emit(progress, phase: .station, completed: 0, total: stationQuestions.count)
        for (index, question) in stationQuestions.enumerated() {
            let firstAnswer = try castor.answer(question.handoff)
            let first = pollux.confirm(question, answer: firstAnswer, storage: storage)
            let second = try secondStrikeIfNeeded(question: question, first: first)
            accumulator.record(first.checks)
            if let second {
                divergences.append(contentsOf: divergenceEvidence(first: first, second: second))
            }
            emitPeriodic(progress, phase: .station, completed: index + 1, total: stationQuestions.count)
        }

        let relationshipTotal = storage.relationships.count
        emit(progress, phase: .exactRelationship, completed: 0, total: relationshipTotal)
        var relationshipCompleted = 0
        var relationshipCursor = pollux.makeRelationshipQuestionCursor(storage: storage)
        while let question = try relationshipCursor.next() {
            let firstAnswer = try castor.answer(question.handoff)
            let first = pollux.confirm(question, answer: firstAnswer, storage: storage)
            let second = try secondStrikeIfNeeded(question: question, first: first)
            accumulator.record(first.checks)
            if let second {
                divergences.append(contentsOf: divergenceEvidence(first: first, second: second))
            }
            relationshipCompleted += 1
            emitPeriodic(
                progress,
                phase: .exactRelationship,
                completed: relationshipCompleted,
                total: relationshipTotal
            )
        }

        let eclipseQuestions = try pollux.makeEclipseQuestions(storage: storage)
        emit(progress, phase: .eclipse, completed: 0, total: eclipseQuestions.count)
        for (index, question) in eclipseQuestions.enumerated() {
            let firstAnswer = try castor.answer(question.handoff)
            let first = pollux.confirm(question, answer: firstAnswer, storage: storage)
            let second = try secondStrikeIfNeeded(question: question, first: first)
            accumulator.record(first.checks)
            if let second {
                divergences.append(contentsOf: divergenceEvidence(first: first, second: second))
            }
            emitPeriodic(progress, phase: .eclipse, completed: index + 1, total: eclipseQuestions.count)
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
        let freshQuestions = try freshPollux.makeStationQuestions(storage: storage)
        guard let freshQuestion = freshQuestions.first(where: { $0.address == question.address }) else {
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
        first: PolluxConfirmation
    ) throws -> PolluxConfirmation? {
        guard !first.isResonant else { return nil }
        let freshPollux = try Pollux(candidate: candidate)
        let freshCastor = try Castor(candidate: candidate)
        var cursor = freshPollux.makeRelationshipQuestionCursor(storage: storage)
        while let freshQuestion = try cursor.next() {
            if freshQuestion.address == question.address {
                return freshPollux.confirm(
                    freshQuestion,
                    answer: try freshCastor.answer(freshQuestion.handoff),
                    storage: storage
                )
            }
        }
        return nondeterministicFallback(first)
    }

    private func secondStrikeIfNeeded(
        question: PolluxEclipseQuestion,
        first: PolluxConfirmation
    ) throws -> PolluxConfirmation? {
        guard !first.isResonant else { return nil }
        let freshPollux = try Pollux(candidate: candidate)
        let freshCastor = try Castor(candidate: candidate)
        let freshQuestions = try freshPollux.makeEclipseQuestions(storage: storage)
        guard let freshQuestion = freshQuestions.first(where: { $0.address == question.address }) else {
            return nondeterministicFallback(first)
        }
        return freshPollux.confirm(
            freshQuestion,
            answer: try freshCastor.answer(freshQuestion.handoff),
            storage: storage
        )
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

    private func emit(
        _ progress: ((DioscuriCertificationProgress) -> Void)?,
        phase: DioscuriCertificationPhase,
        completed: Int,
        total: Int
    ) {
        progress?(DioscuriCertificationProgress(
            phase: phase,
            completed: completed,
            total: total
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
