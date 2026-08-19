import Foundation
import XCTest
@testable import OrboCore

final class MundaneTimespineForgeTests: XCTestCase {
    private struct LinearReference: ForgeEphemerisReference {
        let origin: Double
        let baseLongitude: Double
        let speed: Double

        func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneForgeState {
            MundaneForgeState(
                longitudeDegrees: baseLongitude + speed * (julianDay.value - origin),
                longitudinalSpeedDegreesPerDay: speed
            )!
        }
    }

    private struct TurningReference: ForgeEphemerisReference {
        let origin: Double

        func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneForgeState {
            let t = julianDay.value - origin
            let x = t - 2
            return MundaneForgeState(
                longitudeDegrees: 10 + x * x,
                longitudinalSpeedDegreesPerDay: 2 * x
            )!
        }
    }

    private enum LinearHephaestusRecipe: HephaestusTimespineRecipe {
        static var start: JulianDay { JulianDay(1_000)! }
        static var end: JulianDay { JulianDay(1_010)! }
        static var recipeIdentifier: String { "xctest-linear-timespine" }
        static var recipeVersion: UInt16 { 1 }
        static var artifactContract: HephaestusTimespineArtifactContract {
            HephaestusTimespineArtifactContract(
                bodyCount: 1,
                bodyOccurrenceCount: 10,
                relationshipCount: 0,
                eclipseCount: 0
            )!
        }

        static func forgePlan(
            astronomicalSourceVersion: String
        ) -> MundaneTimespineForgePlan {
            let contract = MundaneTimespineBodyContract(
                body: .sun,
                celestialResolutionDegrees: 1,
                markerBodies: [],
                constructionRecordCount: 10
            )!
            let bodyPlan = MundaneTimespineForgeBodyPlan(
                contract: contract,
                scanStepDays: 0.5
            )!
            return MundaneTimespineForgePlan(
                spanName: "Hephaestus linear fixture",
                astronomicalSource: "deterministic XCTest sky",
                astronomicalSourceVersion: astronomicalSourceVersion,
                supportedStart: start,
                supportedEnd: end,
                bodyPlans: [bodyPlan],
                verifiesConstructionRecordCounts: true,
                verifiesMarkerUniqueness: true
            )!
        }
    }

    private enum MissingRelationshipHephaestusRecipe: HephaestusTimespineRecipe {
        static var recipeIdentifier: String { "xctest-incomplete-timespine" }
        static var recipeVersion: UInt16 { 1 }
        static var artifactContract: HephaestusTimespineArtifactContract {
            HephaestusTimespineArtifactContract(
                bodyCount: 1,
                bodyOccurrenceCount: 10,
                relationshipCount: 1,
                eclipseCount: 0
            )!
        }

        static func forgePlan(
            astronomicalSourceVersion: String
        ) -> MundaneTimespineForgePlan {
            LinearHephaestusRecipe.forgePlan(
                astronomicalSourceVersion: astronomicalSourceVersion
            )
        }
    }

    func testP22RecipeOwnsP22PlanAndCelestialBoundaryLaw() {
        let plan = MundaneTimespineP22ForgeRecipe.plan(astronomicalSourceVersion: "test")

        XCTAssertEqual(plan.spanName, MundaneTimespineP22.spanName)
        XCTAssertEqual(plan.supportedStart, MundaneTimespineP22.startJulianDay)
        XCTAssertEqual(plan.supportedEnd, MundaneTimespineP22.endJulianDay)
        XCTAssertEqual(plan.bodyPlans.map { $0.contract.body }, MundaneBody.canonicalOrder)
        XCTAssertEqual(
            plan.bodyPlans.map { $0.contract.celestialResolutionDegrees },
            MundaneTimespineP22.profiles.map(\.celestialResolutionDegrees)
        )
        XCTAssertTrue(plan.verifiesConstructionRecordCounts)
        XCTAssertTrue(plan.verifiesMarkerUniqueness)
        XCTAssertEqual(plan.astronomicalSource, MundaneTimespineP22ForgeRecipe.astronomicalSource)
        XCTAssertEqual(plan.astronomicalSourceVersion, "test")
        XCTAssertTrue(MundaneTimespineP22ForgeRecipe.astronomicalSource.contains("DE441"))
        XCTAssertEqual(MundaneTimespineP22ForgeRecipe.canonicalAstronomicalSourceVersion, "2.10.03")
        XCTAssertEqual(AstroDNA.codec, 4)
    }

    func testP22RecipeDeclaresCompleteHephaestusCandidateContract() {
        let contract = MundaneTimespineP22ForgeRecipe.artifactContract

        XCTAssertEqual(MundaneTimespineP22ForgeRecipe.recipeIdentifier, "p22-pluto-zeitgeist")
        XCTAssertEqual(MundaneTimespineP22ForgeRecipe.recipeVersion, 1)
        XCTAssertEqual(contract.bodyCount, 11)
        XCTAssertEqual(contract.bodyOccurrenceCount, 1_811_967)
        XCTAssertEqual(contract.stationCount, 17_535)
        XCTAssertEqual(contract.retrogradePassageCount, 8_770)
        XCTAssertEqual(contract.relationshipCount, 770_293)
        XCTAssertEqual(contract.eclipseCount, 1_133)
    }

    func testGenericForgeManufacturesArbitraryDirectCelestialSpanBoundToCivicUT() throws {
        let start = JulianDay(1_000)!
        let end = JulianDay(1_010)!
        let contract = MundaneTimespineBodyContract(
            body: .sun,
            celestialResolutionDegrees: 1,
            markerBodies: [],
            constructionRecordCount: 10
        )!
        let bodyPlan = MundaneTimespineForgeBodyPlan(contract: contract, scanStepDays: 0.5)!
        let plan = MundaneTimespineForgePlan(
            spanName: "Forge linear fixture",
            astronomicalSource: "deterministic XCTest sky",
            astronomicalSourceVersion: "1",
            supportedStart: start,
            supportedEnd: end,
            bodyPlans: [bodyPlan],
            verifiesConstructionRecordCounts: true,
            verifiesMarkerUniqueness: true
        )!

        let product = try MundaneTimespineForge.manufacture(
            plan: plan,
            reference: LinearReference(origin: start.value, baseLongitude: 0, speed: 1)
        )
        let body = try XCTUnwrap(product.body(.sun))

        XCTAssertEqual(product.spanName, "Forge linear fixture")
        XCTAssertEqual(product.totalOccurrenceCount, 10)
        XCTAssertEqual(body.occurrences.map(\.focalCelestialTick), Array(0..<10))
        XCTAssertTrue(body.occurrences.allSatisfy { $0.sequenceDirection == .increasing })
        XCTAssertEqual(body.occurrences.first?.civicOffsetSeconds, 0)
        XCTAssertEqual(body.occurrences.last?.civicOffsetSeconds, 9 * 86_400)
        XCTAssertEqual(body.stations.count, 0)
        XCTAssertEqual(body.retrogradePassages.count, 0)
    }

    func testForgeStationsAreTurnsInCelestialTimeMapping() throws {
        let start = JulianDay(2_000)!
        let end = JulianDay(2_004)!
        let contract = MundaneTimespineBodyContract(
            body: .mercury,
            celestialResolutionDegrees: 1,
            markerBodies: [],
            constructionRecordCount: 8
        )!
        let bodyPlan = MundaneTimespineForgeBodyPlan(contract: contract, scanStepDays: 0.5)!
        let plan = MundaneTimespineForgePlan(
            spanName: "Forge station fixture",
            astronomicalSource: "deterministic XCTest sky",
            astronomicalSourceVersion: "1",
            supportedStart: start,
            supportedEnd: end,
            bodyPlans: [bodyPlan],
            verifiesConstructionRecordCounts: true,
            verifiesMarkerUniqueness: false
        )!

        let product = try MundaneTimespineForge.manufacture(
            plan: plan,
            reference: TurningReference(origin: start.value)
        )
        let body = try XCTUnwrap(product.body(.mercury))
        let station = try XCTUnwrap(body.stations.first)

        XCTAssertEqual(body.occurrences.count, 8)
        XCTAssertEqual(body.stations.count, 1)
        XCTAssertEqual(station.julianDay.value, start.value + 2, accuracy: 1e-10)
        XCTAssertEqual(station.celestialTimeDegrees, 10, accuracy: 1e-10)
        XCTAssertEqual(station.sequenceBefore, .decreasing)
        XCTAssertEqual(station.sequenceAfter, .increasing)
        XCTAssertEqual(station.motionAfter, .direct)
        XCTAssertEqual(body.retrogradePassages.count, 1)
        XCTAssertEqual(body.retrogradeCrossingCount, 5)
    }

    func testP22RecipeRejectsFalsePlutoZeroAriesBoundaryBeforeManufacture() {
        let reference = LinearReference(
            origin: MundaneTimespineP22.startJulianDay.value,
            baseLongitude: 20,
            speed: 1
        )

        XCTAssertThrowsError(
            try MundaneTimespineP22ForgeRecipe.manufacture(
                astronomicalSourceVersion: "test",
                reference: reference
            )
        ) { error in
            XCTAssertEqual(error as? MundaneTimespineP22ForgeRecipeError, .boundaryMismatch)
        }
    }

    func testHephaestusMintsDeterministicCelestialFirstCandidateForArbitraryRecipe() throws {
        let reference = LinearReference(
            origin: LinearHephaestusRecipe.start.value,
            baseLongitude: 0,
            speed: 1
        )

        let first = try Hephaestus.manufactureCandidate(
            recipe: LinearHephaestusRecipe.self,
            astronomicalSourceVersion: "fixture-1",
            reference: reference
        )
        let second = try Hephaestus.manufactureCandidate(
            recipe: LinearHephaestusRecipe.self,
            astronomicalSourceVersion: "fixture-1",
            reference: reference
        )

        XCTAssertTrue(Hephaestus.celestialTimeFirst)
        XCTAssertEqual(Hephaestus.candidateIdentityAlgorithm, "SHA-256")
        XCTAssertEqual(Hephaestus.runtimeRole, "none")
        XCTAssertEqual(MundaneTimespineStorageFormat.identifier, "ORBOTS01")
        XCTAssertEqual(first.artifactData, second.artifactData)
        XCTAssertEqual(first.identity, second.identity)
        XCTAssertEqual(first.identity.sha256.count, 64)
        XCTAssertEqual(first.forgeRecord.candidateSHA256, first.identity.sha256)
        XCTAssertEqual(first.forgeRecord.recipeIdentifier, LinearHephaestusRecipe.recipeIdentifier)
        XCTAssertEqual(first.forgeRecord.recipeVersion, LinearHephaestusRecipe.recipeVersion)
        XCTAssertEqual(first.forgeRecord.storageFamily, "ORBOTS01")
        XCTAssertEqual(first.forgeRecord.storageVersion, 1)
        XCTAssertTrue(first.forgeRecord.celestialTimeFirst)
        XCTAssertEqual(first.forgeRecord.bodyCount, 1)
        XCTAssertEqual(first.forgeRecord.bodyOccurrenceCount, 10)
        XCTAssertEqual(first.forgeRecord.relationshipCount, 0)
        XCTAssertEqual(first.forgeRecord.eclipseCount, 0)
        XCTAssertEqual(first.forgeRecord.artifactByteCount, first.artifactData.count)

        let decoded = try first.artifact.storageImage()
        XCTAssertEqual(decoded.spanName, "Hephaestus linear fixture")
        XCTAssertEqual(decoded.astronomicalSource, "deterministic XCTest sky")
        XCTAssertEqual(decoded.astronomicalSourceVersion, "fixture-1")
        XCTAssertEqual(decoded.bodies.count, 1)
        XCTAssertEqual(decoded.bodies[0].occurrences.count, 10)
    }

    func testHephaestusCandidateIdentityChangesWhenArtifactBytesChange() throws {
        let reference = LinearReference(
            origin: LinearHephaestusRecipe.start.value,
            baseLongitude: 0,
            speed: 1
        )
        let candidate = try Hephaestus.manufactureCandidate(
            recipe: LinearHephaestusRecipe.self,
            astronomicalSourceVersion: "fixture-1",
            reference: reference
        )

        var mutated = candidate.artifactData
        let index = mutated.index(before: mutated.endIndex)
        mutated[index] = mutated[index] ^ 0x01
        let mutatedIdentity = TimespineCandidateIdentity.hash(artifactData: mutated)

        XCTAssertNotEqual(mutatedIdentity, candidate.identity)
    }

    func testHephaestusRefusesIncompleteRecipePayload() {
        let reference = LinearReference(
            origin: LinearHephaestusRecipe.start.value,
            baseLongitude: 0,
            speed: 1
        )

        XCTAssertThrowsError(
            try Hephaestus.manufactureCandidate(
                recipe: MissingRelationshipHephaestusRecipe.self,
                astronomicalSourceVersion: "fixture-1",
                reference: reference
            )
        ) { error in
            XCTAssertEqual(
                error as? HephaestusError,
                .artifactContractMismatch(component: "relationships", expected: 1, actual: 0)
            )
        }
    }

    func testHephaestusRunsP22PreflightBeforeCandidateMinting() {
        let reference = LinearReference(
            origin: MundaneTimespineP22.startJulianDay.value,
            baseLongitude: 20,
            speed: 1
        )

        XCTAssertThrowsError(
            try Hephaestus.manufactureCandidate(
                recipe: MundaneTimespineP22ForgeRecipe.self,
                astronomicalSourceVersion: "fixture-1",
                reference: reference
            )
        ) { error in
            XCTAssertEqual(error as? MundaneTimespineP22ForgeRecipeError, .boundaryMismatch)
        }
    }

    func testDioscuriCertifiesAllFiveScopesCelestialFirst() throws {
        let candidate = try makeDioscuriCandidate(
            bodies: try cleanDioscuriBodies(),
            relationships: [try cleanRelationship()],
            eclipses: [try cleanSolarEclipse()]
        )
        let dioscuri = try Dioscuri(candidate: candidate)

        XCTAssertEqual(Dioscuri.role, "Timespine integrity gate")
        XCTAssertEqual(Dioscuri.order, "Pollux -> Castor -> Pollux")
        XCTAssertEqual(Dioscuri.origin, "celestial")
        XCTAssertEqual(Dioscuri.oracleRole, "none")
        XCTAssertEqual(Dioscuri.forgeRole, "none")
        XCTAssertEqual(Dioscuri.correctionRole, "none")
        XCTAssertEqual(Dioscuri.averagingRole, "none")
        XCTAssertEqual(Dioscuri.verdictTarget, "Hephaestus")
        XCTAssertEqual(Dioscuri.sealAuthority, "Hephaestus")

        switch try dioscuri.certify() {
        case let .certificate(certificate):
            XCTAssertEqual(certificate.contractVersion, 1)
            XCTAssertEqual(certificate.candidateSHA256, candidate.identity.sha256)
            XCTAssertEqual(certificate.recipeIdentifier, "xctest-dioscuri")
            XCTAssertEqual(certificate.storageVersion, 1)
            XCTAssertEqual(certificate.scopeTallies.count, DioscuriScope.allCases.count)
            XCTAssertEqual(tally(.bodyOccurrence, in: certificate.scopeTallies)?.questions, 12)
            XCTAssertEqual(tally(.marker, in: certificate.scopeTallies)?.questions, 3)
            XCTAssertEqual(tally(.motion, in: certificate.scopeTallies)?.questions, 21)
            XCTAssertEqual(tally(.exactRelationship, in: certificate.scopeTallies)?.questions, 1)
            XCTAssertEqual(tally(.eclipse, in: certificate.scopeTallies)?.questions, 1)
            XCTAssertEqual(certificate.quantizedCoincidences, 0)
        case .rejection:
            XCTFail("clean Dioscuri fixture should certify")
        }
    }

    func testDioscuriAdmitsKnownIntegerSecondMarkerQuantizationAtTenthDegreeResolution() throws {
        let candidate = try makeDioscuriCandidate(bodies: try quantizedMarkerBodies())
        let pollux = try Pollux(candidate: candidate)
        let address = try XCTUnwrap(PolluxCelestialAddress(
            body: .mercury,
            celestialTick: 170,
            ticksPerDegree: 10,
            markerFingerprint: [PolluxMarkerCell(body: .sun, wholeDegree: 243)!]
        ))
        let report = try Dioscuri(candidate: candidate).strike(try pollux.ask(address))
        let marker = try XCTUnwrap(report.first.checks.first { $0.scope == .marker })

        XCTAssertTrue(report.isResonant)
        XCTAssertNil(report.second)
        XCTAssertEqual(marker.outcome, .quantizedCoincidence)
        XCTAssertTrue(report.divergences.isEmpty)
    }

    func testDioscuriConfirmsDivergenceOnSecondStrikeAndFailsClosed() throws {
        let candidate = try makeDioscuriCandidate(bodies: try divergentMarkerBodies())
        let pollux = try Pollux(candidate: candidate)
        let address = try XCTUnwrap(PolluxCelestialAddress(
            body: .mercury,
            celestialTick: 170,
            ticksPerDegree: 10,
            markerFingerprint: [PolluxMarkerCell(body: .sun, wholeDegree: 243)!]
        ))
        let report = try Dioscuri(candidate: candidate).strike(try pollux.ask(address))
        let divergence = try XCTUnwrap(report.divergences.first)

        XCTAssertFalse(report.isResonant)
        XCTAssertNotNil(report.second)
        XCTAssertEqual(divergence.scope, .marker)
        XCTAssertEqual(divergence.kind, .marker)
        XCTAssertTrue(divergence.deterministic)
        XCTAssertEqual(divergence.firstObserved, divergence.secondObserved)
    }

    func testDioscuriRejectsBrokenCelestialMotionTopology() throws {
        let sun = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .sun,
            ticksPerDegree: 1,
            markerBodies: [],
            occurrences: [
                .init(celestialTick: 10, civicOffsetSeconds: 0, sequenceDirection: .increasing, markerWholeDegrees: []),
                .init(celestialTick: 12, civicOffsetSeconds: 1_000, sequenceDirection: .increasing, markerWholeDegrees: []),
            ],
            stations: [],
            retrogradePassages: []
        ))
        let candidate = try makeDioscuriCandidate(bodies: [sun])

        switch try Dioscuri(candidate: candidate).certify() {
        case .certificate:
            XCTFail("skipped celestial lattice tick must not certify")
        case let .rejection(report):
            let divergence = try XCTUnwrap(report.divergences.first { $0.scope == .motion })
            XCTAssertTrue(divergence.deterministic)
            XCTAssertTrue(divergence.subject.contains("topology"))
        }
    }

    func testDioscuriRejectsRelationshipWhoseCivicOccurrenceContradictsBodyTracts() throws {
        let badRelationship = try cleanRelationship(offsetSeconds: 2_000)
        let candidate = try makeDioscuriCandidate(
            bodies: try cleanDioscuriBodies(),
            relationships: [badRelationship]
        )

        switch try Dioscuri(candidate: candidate).certify() {
        case .certificate:
            XCTFail("relationship bound to the wrong civic occurrence must not certify")
        case let .rejection(report):
            XCTAssertNotNil(report.divergences.first { $0.scope == .exactRelationship })
        }
    }

    func testDioscuriRejectsEclipseDegreeThatContradictsSunMoonTracts() throws {
        let badEclipse = try XCTUnwrap(MundaneTimespineEclipseEvent(
            kind: .solar,
            type: .total,
            eclipseDegree: 20,
            julianDay: JulianDay(1_000 + 1_000.0 / 86_400)!,
            centrality: "central"
        ))
        let candidate = try makeDioscuriCandidate(
            bodies: try cleanDioscuriBodies(),
            eclipses: [badEclipse]
        )

        switch try Dioscuri(candidate: candidate).certify() {
        case .certificate:
            XCTFail("eclipse degree contradicting the luminary tracts must not certify")
        case let .rejection(report):
            XCTAssertNotNil(report.divergences.first { $0.scope == .eclipse })
        }
    }

    func testPolluxQualifiesRepeatedRelationshipCelestialIdentityByRecurrenceOrdinal() throws {
        let candidate = try makeDioscuriCandidate(
            bodies: try cleanDioscuriBodies(),
            relationships: [
                try cleanRelationship(offsetSeconds: 1_000),
                try cleanRelationship(offsetSeconds: 1_500),
            ]
        )
        let storage = try candidate.artifact.storageImage()
        let pollux = try Pollux(candidate: candidate)
        var cursor = pollux.makeRelationshipQuestionCursor(storage: storage)

        let first = try XCTUnwrap(cursor.next())
        let second = try XCTUnwrap(cursor.next())

        XCTAssertEqual(Pollux.relationshipRecurrenceIdentityLaw, "exact celestial geometry + recurrence ordinal / civic UT excluded")
        XCTAssertEqual(first.address.bodyA, second.address.bodyA)
        XCTAssertEqual(first.address.bodyB, second.address.bodyB)
        XCTAssertEqual(first.address.mark, second.address.mark)
        XCTAssertEqual(first.address.orientation, second.address.orientation)
        XCTAssertEqual(first.address.bodyAMicrodegrees, second.address.bodyAMicrodegrees)
        XCTAssertEqual(first.address.bodyBMicrodegrees, second.address.bodyBMicrodegrees)
        XCTAssertEqual(first.address.recurrenceOrdinal, 0)
        XCTAssertEqual(second.address.recurrenceOrdinal, 1)
        XCTAssertEqual(first.handoff.civicOffsetSeconds, 1_000)
        XCTAssertEqual(second.handoff.civicOffsetSeconds, 1_500)
        XCTAssertNil(try cursor.next())
    }

    func testPolluxRejectsDuplicateRelationshipAtSameStoredSecond() throws {
        let candidate = try makeDioscuriCandidate(
            bodies: try cleanDioscuriBodies(),
            relationships: [
                try cleanRelationship(offsetSeconds: 1_000),
                try cleanRelationship(offsetSeconds: 1_000),
            ]
        )
        let storage = try candidate.artifact.storageImage()
        let pollux = try Pollux(candidate: candidate)
        var cursor = pollux.makeRelationshipQuestionCursor(storage: storage)

        XCTAssertNoThrow(try cursor.next())
        XCTAssertThrowsError(try cursor.next()) { error in
            XCTAssertEqual(error as? PolluxError, .ambiguousRelationshipIdentity)
        }
    }

    private func tally(
        _ scope: DioscuriScope,
        in tallies: [DioscuriScopeTally]
    ) -> DioscuriScopeTally? {
        tallies.first { $0.scope == scope }
    }

    private func cleanDioscuriBodies() throws -> [MundaneTimespineStoredBody] {
        let sun = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .sun,
            ticksPerDegree: 1,
            markerBodies: [],
            occurrences: [
                .init(celestialTick: 10, civicOffsetSeconds: 0, sequenceDirection: .increasing, markerWholeDegrees: []),
                .init(celestialTick: 11, civicOffsetSeconds: 1_000, sequenceDirection: .increasing, markerWholeDegrees: []),
                .init(celestialTick: 12, civicOffsetSeconds: 2_000, sequenceDirection: .increasing, markerWholeDegrees: []),
            ],
            stations: [],
            retrogradePassages: []
        ))
        let moon = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .moon,
            ticksPerDegree: 1,
            markerBodies: [],
            occurrences: [
                .init(celestialTick: 10, civicOffsetSeconds: 0, sequenceDirection: .increasing, markerWholeDegrees: []),
                .init(celestialTick: 11, civicOffsetSeconds: 1_000, sequenceDirection: .increasing, markerWholeDegrees: []),
                .init(celestialTick: 12, civicOffsetSeconds: 2_000, sequenceDirection: .increasing, markerWholeDegrees: []),
            ],
            stations: [],
            retrogradePassages: []
        ))
        let mercury = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .mercury,
            ticksPerDegree: 1,
            markerBodies: [.sun],
            occurrences: [
                .init(celestialTick: 20, civicOffsetSeconds: 0, sequenceDirection: .increasing, markerWholeDegrees: [10]),
                .init(celestialTick: 21, civicOffsetSeconds: 500, sequenceDirection: .increasing, markerWholeDegrees: [10]),
                .init(celestialTick: 21, civicOffsetSeconds: 1_500, sequenceDirection: .decreasing, markerWholeDegrees: [11]),
            ],
            stations: [
                .init(
                    celestialMicrodegrees: 21_500_000,
                    civicOffsetSeconds: 1_000,
                    motionAfter: .retrograde
                ),
            ],
            retrogradePassages: []
        ))
        let venus = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .venus,
            ticksPerDegree: 1,
            markerBodies: [],
            occurrences: [
                .init(celestialTick: 130, civicOffsetSeconds: 0, sequenceDirection: .increasing, markerWholeDegrees: []),
                .init(celestialTick: 131, civicOffsetSeconds: 1_000, sequenceDirection: .increasing, markerWholeDegrees: []),
                .init(celestialTick: 132, civicOffsetSeconds: 2_000, sequenceDirection: .increasing, markerWholeDegrees: []),
            ],
            stations: [],
            retrogradePassages: []
        ))
        return [venus, mercury, moon, sun]
    }

    private func quantizedMarkerBodies() throws -> [MundaneTimespineStoredBody] {
        let sun = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .sun,
            ticksPerDegree: 10,
            markerBodies: [],
            occurrences: [
                .init(celestialTick: 2_439, civicOffsetSeconds: 4_000, sequenceDirection: .increasing, markerWholeDegrees: []),
                .init(celestialTick: 2_440, civicOffsetSeconds: 4_321, sequenceDirection: .increasing, markerWholeDegrees: []),
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
                .init(celestialTick: 171, civicOffsetSeconds: 4_000, sequenceDirection: .decreasing, markerWholeDegrees: [243]),
                .init(celestialTick: 170, civicOffsetSeconds: 4_321, sequenceDirection: .decreasing, markerWholeDegrees: [243]),
                .init(celestialTick: 169, civicOffsetSeconds: 5_000, sequenceDirection: .decreasing, markerWholeDegrees: [244]),
            ],
            stations: [],
            retrogradePassages: []
        ))
        return [mercury, sun]
    }

    private func divergentMarkerBodies() throws -> [MundaneTimespineStoredBody] {
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
        return [mercury, sun]
    }

    private func cleanRelationship(offsetSeconds: Int64 = 1_000) throws -> MundaneTimespineRelationshipEvent {
        try XCTUnwrap(MundaneTimespineRelationshipEvent(
            bodyA: .sun,
            bodyB: .venus,
            mark: .trine,
            orientation: .bodyBAhead,
            bodyACelestialTimeDegrees: 11,
            bodyBCelestialTimeDegrees: 131,
            julianDay: JulianDay(1_000 + Double(offsetSeconds) / 86_400)!,
            exactAspectResidualArcSeconds: 0
        ))
    }

    private func cleanSolarEclipse() throws -> MundaneTimespineEclipseEvent {
        try XCTUnwrap(MundaneTimespineEclipseEvent(
            kind: .solar,
            type: .total,
            eclipseDegree: 11,
            julianDay: JulianDay(1_000 + 1_000.0 / 86_400)!,
            centrality: "central"
        ))
    }

    private func makeDioscuriCandidate(
        bodies: [MundaneTimespineStoredBody],
        relationships: [MundaneTimespineRelationshipEvent] = [],
        eclipses: [MundaneTimespineEclipseEvent] = []
    ) throws -> TimespineCandidate {
        let image = try XCTUnwrap(MundaneTimespineStorageImage(
            spanName: "Dioscuri XCTest fixture",
            astronomicalSource: "deterministic XCTest sky",
            astronomicalSourceVersion: "1",
            supportedStart: JulianDay(1_000)!,
            supportedEnd: JulianDay(1_001)!,
            bodies: bodies,
            relationships: relationships,
            eclipses: eclipses
        ))
        let data = try image.encodedArtifact()
        let artifact = try MundaneTimespineArtifact(data: data)
        let identity = TimespineCandidateIdentity.hash(artifactData: data)
        let record = TimespineForgeRecord(
            recipeIdentifier: "xctest-dioscuri",
            recipeVersion: 1,
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
            relationshipCount: relationships.count,
            eclipseCount: eclipses.count,
            artifactByteCount: data.count,
            candidateSHA256: identity.sha256
        )
        return TimespineCandidate(identity: identity, artifact: artifact, forgeRecord: record)
    }
}
