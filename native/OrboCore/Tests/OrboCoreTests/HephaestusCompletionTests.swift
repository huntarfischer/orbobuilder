import Foundation
import XCTest
@testable import OrboCore

final class HephaestusCompletionTests: XCTestCase {
    private struct LinearReference: ForgeEphemerisReference {
        let origin: Double
        let baseLongitude: Double

        func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneForgeState {
            MundaneForgeState(
                longitudeDegrees: baseLongitude + (julianDay.value - origin),
                longitudinalSpeedDegreesPerDay: 1
            )!
        }
    }

    private enum RecipeA: HephaestusTimespineRecipe {
        static let start = JulianDay(1_000)!
        static let end = JulianDay(1_002)!
        static var recipeIdentifier: String { "xctest-hephaestus-completion-a" }
        static var recipeVersion: UInt16 { 1 }
        static var resonanceContract: HephaestusResonanceContractIdentity {
            HephaestusResonanceContracts.timespineV1
        }
        static var artifactContract: HephaestusTimespineArtifactContract {
            HephaestusTimespineArtifactContract(
                bodyCount: 1,
                bodyOccurrenceCount: 2,
                relationshipCount: 0,
                eclipseCount: 0
            )!
        }

        static func forgePlan(astronomicalSourceVersion: String) -> MundaneTimespineForgePlan {
            let body = MundaneTimespineForgeBodyPlan(
                contract: MundaneTimespineBodyContract(
                    body: .sun,
                    celestialResolutionDegrees: 1,
                    markerBodies: [],
                    constructionRecordCount: 2
                )!,
                scanStepDays: 0.5
            )!
            return MundaneTimespineForgePlan(
                spanName: "Hephaestus completion fixture",
                astronomicalSource: "deterministic XCTest sky",
                astronomicalSourceVersion: astronomicalSourceVersion,
                supportedStart: start,
                supportedEnd: end,
                bodyPlans: [body],
                verifiesConstructionRecordCounts: true,
                verifiesMarkerUniqueness: true
            )!
        }
    }

    private enum RecipeB: HephaestusTimespineRecipe {
        static var recipeIdentifier: String { "xctest-hephaestus-completion-b" }
        static var recipeVersion: UInt16 { 1 }
        static var resonanceContract: HephaestusResonanceContractIdentity {
            HephaestusResonanceContracts.timespineV1
        }
        static var artifactContract: HephaestusTimespineArtifactContract { RecipeA.artifactContract }
        static func forgePlan(astronomicalSourceVersion: String) -> MundaneTimespineForgePlan {
            RecipeA.forgePlan(astronomicalSourceVersion: astronomicalSourceVersion)
        }
    }

    func testHephaestusCompletesResonantCandidateWithoutChangingArtifact() throws {
        let candidate = try makeCandidate(recipe: RecipeA.self)
        let before = candidate.artifactData
        let testimony = try Dioscuri.testify(candidate: candidate)

        switch Hephaestus.complete(candidate: candidate, testimony: testimony) {
        case let .sealed(result):
            XCTAssertEqual(result.candidate.artifactData, before)
            XCTAssertEqual(result.candidate.identity, candidate.identity)
            XCTAssertEqual(result.seal.candidateSHA256, candidate.identity.sha256)
            XCTAssertEqual(result.seal.artifactByteCount, before.count)
            XCTAssertEqual(result.seal.recipeIdentifier, RecipeA.recipeIdentifier)
            XCTAssertEqual(result.seal.resonanceContract, RecipeA.resonanceContract)
            XCTAssertEqual(result.seal.dioscuriEvidenceSHA256, testimony.evidenceSHA256)
            XCTAssertEqual(result.seal.sealSHA256.count, 64)
            XCTAssertEqual(Hephaestus.resonanceAuthority, "Dioscuri")
            XCTAssertEqual(Hephaestus.overruleRole, "none")
            XCTAssertEqual(Hephaestus.sealMutationRole, "none")
        case let .quarantined(result):
            XCTFail("resonant candidate was quarantined: \(result.reason.rawValue)")
        }
    }

    func testHephaestusSealIsDeterministicForSameCandidateAndTestimony() throws {
        let candidate = try makeCandidate(recipe: RecipeA.self)
        let testimony = try Dioscuri.testify(candidate: candidate)
        let first = try sealed(Hephaestus.complete(candidate: candidate, testimony: testimony))
        let second = try sealed(Hephaestus.complete(candidate: candidate, testimony: testimony))

        XCTAssertEqual(first.seal, second.seal)
        XCTAssertEqual(first.seal.sealSHA256, second.seal.sealSHA256)
    }

    func testHephaestusQuarantinesDioscuriRejectionAndPreservesExactWork() throws {
        let candidate = try makeRejectedCandidate()
        let before = candidate.artifactData
        let testimony = try Dioscuri.testify(candidate: candidate)
        XCTAssertEqual(testimony.result, .rejected)

        let result = try quarantined(Hephaestus.complete(candidate: candidate, testimony: testimony))
        XCTAssertEqual(result.reason, .dioscuriRejected)
        XCTAssertEqual(result.candidate.artifactData, before)
        XCTAssertEqual(result.candidate.identity, candidate.identity)
        if case .rejection = result.testimony.evidence {
            // Expected forensic evidence is preserved intact.
        } else {
            XCTFail("quarantine must preserve the Dioscuri rejection evidence")
        }
    }

    func testHephaestusQuarantinesChangedCandidateIdentityBeforeReadingTestimony() throws {
        let candidate = try makeCandidate(recipe: RecipeA.self)
        let testimony = try Dioscuri.testify(candidate: candidate)
        let wrongIdentity = TimespineCandidateIdentity.hash(artifactData: Data("not-the-artifact".utf8))
        let changed = TimespineCandidate(
            identity: wrongIdentity,
            artifact: candidate.artifact,
            forgeRecord: candidate.forgeRecord
        )

        let result = try quarantined(Hephaestus.complete(candidate: changed, testimony: testimony))
        XCTAssertEqual(result.reason, .candidateIdentityMismatch)
        XCTAssertEqual(result.candidate.artifactData, candidate.artifactData)
    }

    func testHephaestusQuarantinesTestimonyForAnotherCandidate() throws {
        let candidate = try makeCandidate(recipe: RecipeA.self, baseLongitude: 0)
        let other = try makeCandidate(recipe: RecipeA.self, baseLongitude: 10)
        XCTAssertNotEqual(candidate.identity, other.identity)
        let foreignTestimony = try Dioscuri.testify(candidate: other)

        let result = try quarantined(Hephaestus.complete(
            candidate: candidate,
            testimony: foreignTestimony
        ))
        XCTAssertEqual(result.reason, .testimonyCandidateMismatch)
    }

    func testHephaestusQuarantinesWrongRecipeBinding() throws {
        let candidate = try makeCandidate(recipe: RecipeA.self)
        let good = try Dioscuri.testify(candidate: candidate)
        let wrong = replacing(
            good,
            recipeIdentifier: "wrong-recipe"
        )

        let result = try quarantined(Hephaestus.complete(candidate: candidate, testimony: wrong))
        XCTAssertEqual(result.reason, .testimonyRecipeMismatch)
    }

    func testHephaestusQuarantinesWrongResonanceContract() throws {
        let candidate = try makeCandidate(recipe: RecipeA.self)
        let good = try Dioscuri.testify(candidate: candidate)
        let future = HephaestusResonanceContractIdentity(
            identifier: "future-resonance",
            version: 1
        )!
        let wrong = replacing(good, resonanceContract: future)

        let result = try quarantined(Hephaestus.complete(candidate: candidate, testimony: wrong))
        XCTAssertEqual(result.reason, .resonanceContractMismatch)
    }

    func testHephaestusQuarantinesUnsupportedDioscuriContract() throws {
        let candidate = try makeCandidate(recipe: RecipeA.self)
        let good = try Dioscuri.testify(candidate: candidate)
        let wrong = replacing(good, dioscuriContractVersion: Dioscuri.contractVersion + 1)

        let result = try quarantined(Hephaestus.complete(candidate: candidate, testimony: wrong))
        XCTAssertEqual(result.reason, .unsupportedDioscuriContract)
    }

    func testHephaestusQuarantinesMalformedTestimonyEvidenceIdentity() throws {
        let candidate = try makeCandidate(recipe: RecipeA.self)
        let good = try Dioscuri.testify(candidate: candidate)
        let wrong = replacing(good, evidenceSHA256: String(repeating: "0", count: 64))

        let result = try quarantined(Hephaestus.complete(candidate: candidate, testimony: wrong))
        XCTAssertEqual(result.reason, .malformedTestimony)
    }

    func testSameHephaestusCompletionClosesDifferentRecipesWithoutDomainBranches() throws {
        let firstCandidate = try makeCandidate(recipe: RecipeA.self)
        let secondCandidate = try makeCandidate(recipe: RecipeB.self)
        XCTAssertEqual(firstCandidate.artifactData, secondCandidate.artifactData)
        XCTAssertEqual(firstCandidate.identity, secondCandidate.identity)
        XCTAssertNotEqual(firstCandidate.forgeRecord.recipeIdentifier, secondCandidate.forgeRecord.recipeIdentifier)

        let first = try sealed(Hephaestus.complete(
            candidate: firstCandidate,
            testimony: try Dioscuri.testify(candidate: firstCandidate)
        ))
        let second = try sealed(Hephaestus.complete(
            candidate: secondCandidate,
            testimony: try Dioscuri.testify(candidate: secondCandidate)
        ))

        XCTAssertEqual(first.seal.recipeIdentifier, RecipeA.recipeIdentifier)
        XCTAssertEqual(second.seal.recipeIdentifier, RecipeB.recipeIdentifier)
        XCTAssertNotEqual(first.seal.sealSHA256, second.seal.sealSHA256)
    }

    func testManufactureBindsRecipeResonanceContractBeforeDioscuri() throws {
        let candidate = try makeCandidate(recipe: RecipeA.self)
        XCTAssertEqual(candidate.forgeRecord.resonanceContract, RecipeA.resonanceContract)
        XCTAssertEqual(candidate.forgeRecord.candidateSHA256, candidate.identity.sha256)
        XCTAssertEqual(Hephaestus.runtimeRole, "none")
        XCTAssertEqual(Hephaestus.queryRole, "none")
        XCTAssertEqual(Hephaestus.interpretationRole, "none")
    }

    func testAssembledStorageImageUsesTheSameHephaestusMintAsForge() throws {
        let forged = try makeCandidate(recipe: RecipeA.self)
        let image = try forged.artifact.storageImage()
        let assembled = try Hephaestus.manufactureCandidate(
            recipe: RecipeA.self,
            assembledStorageImage: image
        )

        XCTAssertEqual(assembled.artifactData, forged.artifactData)
        XCTAssertEqual(assembled.identity, forged.identity)
        XCTAssertEqual(assembled.forgeRecord.recipeIdentifier, forged.forgeRecord.recipeIdentifier)
        XCTAssertEqual(assembled.forgeRecord.bodyOccurrenceCount, forged.forgeRecord.bodyOccurrenceCount)
    }

    func testAssembledStorageImageRejectsRecipeProvenanceMismatch() throws {
        let forged = try makeCandidate(recipe: RecipeA.self)
        let decoded = try forged.artifact.storageImage()
        let wrong = try XCTUnwrap(MundaneTimespineStorageImage(
            spanName: "not the recipe span",
            astronomicalSource: decoded.astronomicalSource,
            astronomicalSourceVersion: decoded.astronomicalSourceVersion,
            supportedStart: decoded.supportedStart,
            supportedEnd: decoded.supportedEnd,
            bodies: decoded.bodies,
            relationships: decoded.relationships,
            eclipses: decoded.eclipses
        ))

        XCTAssertThrowsError(try Hephaestus.manufactureCandidate(
            recipe: RecipeA.self,
            assembledStorageImage: wrong
        )) { error in
            XCTAssertEqual(error as? HephaestusError, .provenanceMismatch)
        }
    }

    func testHephaestusRehydratesPreservedCandidateAsSameImmutableWork() throws {
        let minted = try makeCandidate(recipe: RecipeA.self)
        let restored = try Hephaestus.rehydrateCandidate(
            recipe: RecipeA.self,
            artifactData: minted.artifactData
        )

        XCTAssertEqual(
            Hephaestus.candidateRehydrationLaw,
            "exact ORBOTS bytes + bound recipe -> same candidate identity"
        )
        XCTAssertEqual(restored.artifactData, minted.artifactData)
        XCTAssertEqual(restored.identity, minted.identity)
        XCTAssertEqual(restored.forgeRecord, minted.forgeRecord)
    }

    func testDioscuriCheckpointResumeMatchesFreshTestimony() throws {
        let candidate = try makeCandidate(recipe: RecipeA.self)
        var captured: DioscuriCertificationCheckpoint?

        XCTAssertThrowsError(try Dioscuri.testify(
            candidate: candidate,
            resumingFrom: nil,
            checkpointHandler: { checkpoint in
                captured = checkpoint
                throw TestFailure.checkpointCaptured
            }
        )) { error in
            guard case TestFailure.checkpointCaptured = error else {
                return XCTFail("unexpected checkpoint interruption: \(error)")
            }
        }

        let checkpoint = try XCTUnwrap(captured)
        XCTAssertEqual(checkpoint.candidateSHA256, candidate.identity.sha256)
        XCTAssertEqual(checkpoint.completed.bodyOccurrence, 2)
        XCTAssertEqual(checkpoint.completed.motionTopology, 0)
        XCTAssertEqual(checkpoint.dioscuriContractVersion, Dioscuri.contractVersion)
        XCTAssertEqual(
            checkpoint.certificationImplementationVersion,
            Dioscuri.certificationImplementationVersion
        )
        XCTAssertEqual(Dioscuri.checkpointLaw, "candidate-bound / whole-question / deterministic-prefix")

        let resumed = try Dioscuri.testify(
            candidate: candidate,
            resumingFrom: checkpoint
        )
        let fresh = try Dioscuri.testify(candidate: candidate)
        XCTAssertEqual(resumed.result, fresh.result)
        XCTAssertEqual(resumed.evidenceSHA256, fresh.evidenceSHA256)
    }

    func testDioscuriCheckpointRejectsInflatedTallyShape() throws {
        let candidate = try makeCandidate(recipe: RecipeA.self)
        var captured: DioscuriCertificationCheckpoint?

        XCTAssertThrowsError(try Dioscuri.testify(
            candidate: candidate,
            resumingFrom: nil,
            checkpointHandler: { checkpoint in
                captured = checkpoint
                throw TestFailure.checkpointCaptured
            }
        ))

        let checkpoint = try XCTUnwrap(captured)
        let inflatedTallies = checkpoint.scopeTallies.map { tally -> DioscuriScopeTally in
            guard tally.scope == .bodyOccurrence else { return tally }
            return DioscuriScopeTally(
                scope: tally.scope,
                questions: tally.questions + 1,
                resonant: tally.resonant + 1,
                quantizedCoincidences: tally.quantizedCoincidences,
                divergent: tally.divergent
            )
        }
        let corrupted = DioscuriCertificationCheckpoint(
            candidate: candidate,
            certificationImplementationVersion: Dioscuri.certificationImplementationVersion,
            completed: checkpoint.completed,
            scopeTallies: inflatedTallies,
            divergences: checkpoint.divergences
        )

        XCTAssertEqual(
            Dioscuri.checkpointValidationLaw,
            "exact scope-count shape + divergence parity / no replay"
        )
        XCTAssertThrowsError(try Dioscuri.testify(
            candidate: candidate,
            resumingFrom: corrupted
        )) { error in
            XCTAssertEqual(error as? DioscuriCheckpointError, .invalidTallies)
        }
    }

    func testP22RecipeBindsCompleteCanonicalArtifactAnatomy() {
        let contract = MundaneTimespineP22ForgeRecipe.artifactContract
        XCTAssertEqual(contract.bodyCount, 11)
        XCTAssertEqual(contract.bodyOccurrenceCount, 1_811_967)
        XCTAssertEqual(contract.stationCount, 17_535)
        XCTAssertEqual(contract.retrogradePassageCount, 8_770)
        XCTAssertEqual(contract.relationshipCount, 770_293)
        XCTAssertEqual(contract.eclipseCount, 1_133)
        XCTAssertEqual(
            MundaneTimespineP22ForgeRecipe.astronomicalSource,
            "Swiss Ephemeris DE441; geocentric tropical apparent ecliptic longitude; UT"
        )
        XCTAssertEqual(MundaneTimespineP22ForgeRecipe.canonicalAstronomicalSourceVersion, "2.10.03")
    }

    func testP22CanonicalInputContractFreezesEveryAdmittedIngredient() {
        XCTAssertEqual(MundaneTimespineP22CanonicalInputs.bodyInputs.count, 11)
        XCTAssertEqual(MundaneTimespineP22CanonicalInputs.sharedMotionInputs.count, 3)
        XCTAssertEqual(MundaneTimespineP22CanonicalInputs.universalEventInputs.count, 3)
        XCTAssertEqual(MundaneTimespineP22CanonicalInputs.all.count, 17)
        XCTAssertEqual(MundaneTimespineP22CanonicalInputs.expectedRelationshipRows, 770_293)
        XCTAssertEqual(MundaneTimespineP22CanonicalInputs.expectedEclipseRows, 1_133)
        XCTAssertTrue(MundaneTimespineP22CanonicalInputs.all.allSatisfy {
            $0.compressedBytes > 0 && $0.sha256.count == 64
        })
        XCTAssertEqual(
            Set(MundaneTimespineP22CanonicalInputs.bodyInputs.compactMap(\.expectedRows)).count,
            11
        )
    }

    func testDioscuriCertificationProgressCoversEveryTimespinePhase() throws {
        let candidate = try makeCandidate(recipe: RecipeA.self)
        var updates: [DioscuriCertificationProgress] = []
        let verdict = try Dioscuri(candidate: candidate).certify { updates.append($0) }

        guard case .certificate = verdict else {
            return XCTFail("clean fixture should certify")
        }
        XCTAssertEqual(Set(updates.map(\.phase)), Set(DioscuriCertificationPhase.allCases))
        XCTAssertEqual(updates.first { $0.phase == .bodyOccurrence }?.total, 2)
        XCTAssertEqual(updates.first { $0.phase == .motionTopology }?.total, 1)
        XCTAssertEqual(updates.first { $0.phase == .station }?.total, 0)
        XCTAssertEqual(updates.first { $0.phase == .exactRelationship }?.total, 0)
        XCTAssertEqual(updates.first { $0.phase == .eclipse }?.total, 0)
        XCTAssertEqual(Dioscuri.exhaustiveExecutionLaw, "streamed / bounded working set")
    }

    private func makeCandidate<R: HephaestusTimespineRecipe>(
        recipe: R.Type,
        baseLongitude: Double = 0
    ) throws -> TimespineCandidate {
        try Hephaestus.manufactureCandidate(
            recipe: recipe,
            astronomicalSourceVersion: "fixture-1",
            reference: LinearReference(origin: RecipeA.start.value, baseLongitude: baseLongitude)
        )
    }

    private func makeRejectedCandidate() throws -> TimespineCandidate {
        let sun = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .sun,
            ticksPerDegree: 10,
            markerBodies: [],
            occurrences: [
                .init(celestialTick: 2_440, civicOffsetSeconds: 4_000, sequenceDirection: .increasing, markerWholeDegrees: []),
                .init(celestialTick: 2_441, civicOffsetSeconds: 5_000, sequenceDirection: .increasing, markerWholeDegrees: []),
            ],
            stations: [],
            retrogradePassages: []
        ))
        let mercury = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .mercury,
            ticksPerDegree: 10,
            markerBodies: [.sun],
            occurrences: [
                .init(celestialTick: 171, civicOffsetSeconds: 4_000, sequenceDirection: .decreasing, markerWholeDegrees: [244]),
                .init(celestialTick: 170, civicOffsetSeconds: 4_321, sequenceDirection: .decreasing, markerWholeDegrees: [243]),
                .init(celestialTick: 169, civicOffsetSeconds: 5_000, sequenceDirection: .decreasing, markerWholeDegrees: [244]),
            ],
            stations: [],
            retrogradePassages: []
        ))
        return try makeManualCandidate(
            recipeIdentifier: "xctest-hephaestus-rejection",
            bodies: [mercury, sun]
        )
    }

    private func makeManualCandidate(
        recipeIdentifier: String,
        bodies: [MundaneTimespineStoredBody]
    ) throws -> TimespineCandidate {
        let image = try XCTUnwrap(MundaneTimespineStorageImage(
            spanName: "Hephaestus rejection fixture",
            astronomicalSource: "deterministic XCTest sky",
            astronomicalSourceVersion: "1",
            supportedStart: JulianDay(1_000)!,
            supportedEnd: JulianDay(1_001)!,
            bodies: bodies,
            relationships: [],
            eclipses: []
        ))
        let data = try image.encodedArtifact()
        let artifact = try MundaneTimespineArtifact(data: data)
        let identity = TimespineCandidateIdentity.hash(artifactData: data)
        let record = TimespineForgeRecord(
            recipeIdentifier: recipeIdentifier,
            recipeVersion: 1,
            resonanceContract: HephaestusResonanceContracts.timespineV1,
            spanName: image.spanName,
            astronomicalSource: image.astronomicalSource,
            astronomicalSourceVersion: image.astronomicalSourceVersion,
            storageFamily: MundaneTimespineStorageFormat.identifier,
            storageVersion: MundaneTimespineStorageFormat.version,
            celestialTimeFirst: MundaneTimespineStorageFormat.celestialTimeFirst,
            bodyCount: bodies.count,
            bodyOccurrenceCount: bodies.reduce(0) { $0 + $1.occurrences.count },
            stationCount: bodies.reduce(0) { $0 + $1.stations.count },
            retrogradePassageCount: bodies.reduce(0) { $0 + $1.retrogradePassages.count },
            relationshipCount: 0,
            eclipseCount: 0,
            artifactByteCount: data.count,
            candidateSHA256: identity.sha256
        )
        return TimespineCandidate(identity: identity, artifact: artifact, forgeRecord: record)
    }

    private func replacing(
        _ testimony: DioscuriTestimony,
        candidateSHA256: String? = nil,
        recipeIdentifier: String? = nil,
        resonanceContract: HephaestusResonanceContractIdentity? = nil,
        dioscuriContractVersion: UInt16? = nil,
        evidenceSHA256: String? = nil
    ) -> DioscuriTestimony {
        DioscuriTestimony(
            candidateSHA256: candidateSHA256 ?? testimony.candidateSHA256,
            recipeIdentifier: recipeIdentifier ?? testimony.recipeIdentifier,
            recipeVersion: testimony.recipeVersion,
            resonanceContract: resonanceContract ?? testimony.resonanceContract,
            dioscuriContractVersion: dioscuriContractVersion ?? testimony.dioscuriContractVersion,
            result: testimony.result,
            evidenceSHA256: evidenceSHA256 ?? testimony.evidenceSHA256,
            evidence: testimony.evidence
        )
    }

    private func sealed(_ disposition: HephaestusDisposition) throws -> HephaestusSealedArtifact {
        switch disposition {
        case let .sealed(result): return result
        case let .quarantined(result):
            XCTFail("expected seal, got quarantine: \(result.reason.rawValue)")
            throw TestFailure.unexpectedDisposition
        }
    }

    private func quarantined(_ disposition: HephaestusDisposition) throws -> HephaestusQuarantinedArtifact {
        switch disposition {
        case let .quarantined(result): return result
        case .sealed:
            XCTFail("expected quarantine, got seal")
            throw TestFailure.unexpectedDisposition
        }
    }

    private enum TestFailure: Error {
        case unexpectedDisposition
        case checkpointCaptured
    }
}
