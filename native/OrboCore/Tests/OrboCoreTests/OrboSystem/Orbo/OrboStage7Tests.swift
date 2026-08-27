import XCTest
@testable import OrboCore

final class OrboStage7Tests: XCTestCase {
    func testBigThreeCannotBeginBeforeNativeTruthReady() throws {
        var (orbo, _, _) = try entrustedDummyTraveler()
        _ = try orbo.beginAstrosphereIntroduction()
        _ = try orbo.advanceAstrosphereIntroduction()

        XCTAssertThrowsError(
            try orbo.beginBigThree(with: OrboPipelineFixture.bigThreeTruth)
        ) { error in
            XCTAssertEqual(error as? OrboBigThreeFailure, .nativeTruthUnavailable)
        }

        XCTAssertNil(orbo.bigThreeSession)
        XCTAssertEqual(orbo.frontOfHouse, .introducingAstrosphere)
        XCTAssertEqual(orbo.backOfHouse, .engravingInProgress)
    }

    func testBigThreeCannotBeginBeforeFOHReachesLayoutEvenWhenNativeTruthIsReady() throws {
        var (orbo, _, _) = try entrustedDummyTraveler()
        orbo.receiveBackOfHouseResult(.nativeTruthReady)

        XCTAssertThrowsError(
            try orbo.beginBigThree(with: OrboPipelineFixture.bigThreeTruth)
        ) { error in
            XCTAssertEqual(
                error as? OrboBigThreeFailure,
                .astrosphereIntroductionIncomplete
            )
        }

        XCTAssertNil(orbo.bigThreeSession)
        XCTAssertEqual(orbo.frontOfHouse, .onboarding)
        XCTAssertEqual(orbo.backOfHouse, .nativeReady)
    }

    func testBigThreeFollowsCanonicalPartFourAndReadsSuppliedTruthExactly() throws {
        var (orbo, _, ticketID) = try readyForBigThree()
        let commissionBefore = try XCTUnwrap(orbo.engravingCommission)

        var beat = try orbo.beginBigThree(with: OrboPipelineFixture.bigThreeTruth)
        XCTAssertEqual(beat.progress, .moment)
        XCTAssertEqual(
            beat.orboLines,
            ["The moment you were born is as unique to you as your DNA."]
        )

        beat = try orbo.advanceBigThree()
        XCTAssertEqual(beat.progress, .ascendant)
        XCTAssertEqual(
            beat.orboLines,
            ["When you were born, Gemini was on the horizon."]
        )

        beat = try orbo.advanceBigThree()
        XCTAssertEqual(beat.progress, .moon)
        XCTAssertEqual(
            beat.orboLines,
            ["When you were born, the Moon was in Leo."]
        )

        beat = try orbo.advanceBigThree()
        XCTAssertEqual(beat.progress, .sun)
        XCTAssertEqual(
            beat.orboLines,
            ["When you were born, the Sun was in Pisces."]
        )

        beat = try orbo.advanceBigThree()
        XCTAssertEqual(beat.progress, .bigThree)
        XCTAssertEqual(
            beat.orboLines,
            ["Your Sun, Moon and rising are known as your Big Three."]
        )

        beat = try orbo.advanceBigThree()
        XCTAssertEqual(beat.progress, .focus)
        XCTAssertEqual(
            beat.orboLines,
            [
                "The Big Three focus on how you show up in the world. And how the astrosphere shows up for you."
            ]
        )

        beat = try orbo.advanceBigThree()
        XCTAssertEqual(beat.progress, .tourChoice)
        XCTAssertEqual(beat.orboLines, ["Would you like a tour?"])

        XCTAssertEqual(orbo.bigThreeSession?.truth, OrboPipelineFixture.bigThreeTruth)
        XCTAssertEqual(orbo.frontOfHouse, .introducingAstrosphere)
        XCTAssertEqual(orbo.backOfHouse, .nativeReady)
        XCTAssertEqual(orbo.engravingTicketID, ticketID)
        XCTAssertEqual(orbo.engravingCommission, commissionBefore)
    }

    func testTourChoiceIsFOHOnlyAndBothCanonicalChoicesCompleteOnboarding() throws {
        for choice in [OrboTourChoice.noThanks, .yesPlease] {
            var (orbo, _, ticketID) = try readyForBigThree()
            let commissionBefore = try XCTUnwrap(orbo.engravingCommission)

            _ = try advanceToTourChoice(&orbo)

            XCTAssertThrowsError(
                try orbo.advanceBigThree()
            ) { error in
                XCTAssertEqual(error as? OrboBigThreeFailure, .tourResponseRequired)
            }

            let beat = try orbo.respondToBigThreeTour(choice)

            XCTAssertEqual(beat.progress, .complete)
            XCTAssertEqual(beat.orboLines, ["The astrosphere awaits!"])
            XCTAssertEqual(orbo.bigThreeSession?.tourChoice, choice)
            XCTAssertEqual(orbo.frontOfHouse, .ready)
            XCTAssertEqual(orbo.backOfHouse, .nativeReady)
            XCTAssertEqual(orbo.engravingTicketID, ticketID)
            XCTAssertEqual(orbo.engravingCommission, commissionBefore)
        }
    }

    func testBigThreePresentationDoesNotDeriveOrMutateChartMatter() throws {
        var (orbo, _, _) = try readyForBigThree()
        let commissionBefore = try XCTUnwrap(orbo.engravingCommission)

        XCTAssertNil(commissionBefore.contents.topos)
        XCTAssertNil(commissionBefore.contents.astroDNA)
        XCTAssertNil(commissionBefore.contents.tapestry)
        XCTAssertFalse(commissionBefore.contents.engraved)

        _ = try orbo.beginBigThree(with: OrboPipelineFixture.bigThreeTruth)
        _ = try orbo.advanceBigThree()
        _ = try orbo.advanceBigThree()
        _ = try orbo.advanceBigThree()

        XCTAssertEqual(orbo.engravingCommission, commissionBefore)
        XCTAssertNil(orbo.engravingCommission?.contents.topos)
        XCTAssertNil(orbo.engravingCommission?.contents.astroDNA)
        XCTAssertNil(orbo.engravingCommission?.contents.tapestry)
        XCTAssertEqual(orbo.engravingCommission?.contents.engraved, false)
        XCTAssertEqual(orbo.bigThreeSession?.truth, OrboPipelineFixture.bigThreeTruth)
    }

    private func advanceToTourChoice(_ orbo: inout Orbo) throws -> OrboBigThreeBeat {
        var beat = try orbo.beginBigThree(with: OrboPipelineFixture.bigThreeTruth)
        for _ in 0..<6 {
            beat = try orbo.advanceBigThree()
        }
        return beat
    }

    private func readyForBigThree() throws -> (Orbo, HermesCourier, HermesTicketID) {
        var (orbo, hermes, ticketID) = try entrustedDummyTraveler()
        _ = try orbo.beginAstrosphereIntroduction()
        _ = try orbo.advanceAstrosphereIntroduction()
        orbo.receiveBackOfHouseResult(.nativeTruthReady)
        return (orbo, hermes, ticketID)
    }

    private func entrustedDummyTraveler() throws -> (Orbo, HermesCourier, HermesTicketID) {
        var orbo = Orbo()

        _ = orbo.beginOnboarding()
        _ = try orbo.respondToOnboarding(.name(OrboPipelineFixture.name))
        _ = try orbo.respondToOnboarding(
            .astrologyInterest(OrboPipelineFixture.astrologyInterest)
        )
        _ = try orbo.respondToOnboarding(.birthDate(OrboPipelineFixture.birthDate))
        _ = try orbo.respondToOnboarding(
            .birthLocation(OrboPipelineFixture.birthLocation)
        )
        _ = try orbo.respondToOnboarding(.birthTimeKnowledge(.known))
        _ = try orbo.respondToOnboarding(.birthTime(OrboPipelineFixture.birthTime))
        _ = try orbo.commissionEngraving(
            subjectID: OrboPipelineFixture.subjectID,
            packageID: OrboPipelineFixture.packageID
        )

        var hermes = HermesCourier()
        let ticketID = try orbo.entrustEngraving(
            to: &hermes,
            occurredAt: OrboPipelineFixture.handoffAt
        )

        return (orbo, hermes, ticketID)
    }
}
