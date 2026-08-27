import XCTest
@testable import OrboCore

final class OrboStage8Tests: XCTestCase {
    func testOneTravelerRunsTheCompleteOrboMVPWithoutBackstageLeakage() throws {
        var playerFacing: [Any] = []
        var orbo = Orbo()

        XCTAssertEqual(orbo.frontOfHouse, .resting)
        XCTAssertEqual(orbo.backOfHouse, .idle)
        playerFacing.append(orbo.frontOfHouse)

        var onboardingBeat = orbo.beginOnboarding()
        XCTAssertEqual(onboardingBeat.progress, .requestingName)
        playerFacing.append(onboardingBeat)

        onboardingBeat = try orbo.respondToOnboarding(.name(OrboPipelineFixture.name))
        XCTAssertEqual(onboardingBeat.progress, .requestingReadingDepth)
        playerFacing.append(onboardingBeat)

        onboardingBeat = try orbo.respondToOnboarding(
            .astrologyInterest(OrboPipelineFixture.astrologyInterest)
        )
        XCTAssertEqual(onboardingBeat.progress, .requestingBirthDate)
        playerFacing.append(onboardingBeat)

        onboardingBeat = try orbo.respondToOnboarding(.birthDate(OrboPipelineFixture.birthDate))
        XCTAssertEqual(onboardingBeat.progress, .requestingBirthLocation)
        playerFacing.append(onboardingBeat)

        onboardingBeat = try orbo.respondToOnboarding(
            .birthLocation(OrboPipelineFixture.birthLocation)
        )
        XCTAssertEqual(onboardingBeat.progress, .requestingBirthTimeKnowledge)
        playerFacing.append(onboardingBeat)

        onboardingBeat = try orbo.respondToOnboarding(.birthTimeKnowledge(.known))
        XCTAssertEqual(onboardingBeat.progress, .requestingBirthTime)
        playerFacing.append(onboardingBeat)

        onboardingBeat = try orbo.respondToOnboarding(.birthTime(OrboPipelineFixture.birthTime))
        XCTAssertEqual(onboardingBeat.progress, .readyForEngraving)
        XCTAssertEqual(orbo.onboardingSession?.readingDepth, OrboPipelineFixture.readingDepth)
        playerFacing.append(onboardingBeat)

        let package = try orbo.commissionEngraving(
            subjectID: OrboPipelineFixture.subjectID,
            packageID: OrboPipelineFixture.packageID
        )

        XCTAssertEqual(package.packageID, OrboPipelineFixture.packageID)
        XCTAssertEqual(package.subjectID, OrboPipelineFixture.subjectID)
        XCTAssertEqual(package.sender, OrboOnboarding.orboAddress)
        XCTAssertEqual(package.kind, OrboOnboarding.engravingPackageKind)
        XCTAssertEqual(package.addresses, OrboOnboarding.engravingItinerary)
        XCTAssertNil(package.contents.topos)
        XCTAssertNil(package.contents.astroDNA)
        XCTAssertNil(package.contents.tapestry)
        XCTAssertFalse(package.contents.engraved)
        XCTAssertEqual(orbo.backOfHouse, .engravingCommissioned)
        XCTAssertEqual(orbo.frontOfHouse, .onboarding)
        playerFacing.append(orbo.frontOfHouse)

        var hermes = HermesCourier()
        let ticketID = try orbo.entrustEngraving(
            to: &hermes,
            occurredAt: OrboPipelineFixture.handoffAt
        )

        let openedEvents = hermes.manifest.events(for: ticketID)
        XCTAssertEqual(openedEvents.count, 1)
        XCTAssertEqual(openedEvents.first?.kind, .ticketOpened)
        XCTAssertEqual(openedEvents.first?.packageID, OrboPipelineFixture.packageID)
        XCTAssertEqual(hermes.manifest.currentState(for: ticketID), .unresolved)
        XCTAssertEqual(orbo.engravingTicketID, ticketID)
        XCTAssertEqual(orbo.backOfHouse, .engravingInProgress)

        let introduction = try orbo.beginAstrosphereIntroduction()
        XCTAssertEqual(introduction.progress, .astrosphereIntroduction)
        XCTAssertEqual(orbo.frontOfHouse, .introducingAstrosphere)
        XCTAssertEqual(orbo.backOfHouse, .engravingInProgress)
        playerFacing.append(orbo.frontOfHouse)
        playerFacing.append(introduction)

        let manifestWhileFOHHosts = hermes.manifest.events(for: ticketID)
        let frontBeforeNativeReady = orbo.frontOfHouse
        let introductionBeforeNativeReady = orbo.astrosphereIntroductionProgress

        orbo.receiveBackOfHouseResult(.nativeTruthReady)

        XCTAssertEqual(orbo.backOfHouse, .nativeReady)
        XCTAssertTrue(orbo.canEnterBigThree)
        XCTAssertEqual(orbo.frontOfHouse, frontBeforeNativeReady)
        XCTAssertEqual(orbo.astrosphereIntroductionProgress, introductionBeforeNativeReady)
        XCTAssertEqual(hermes.manifest.events(for: ticketID), manifestWhileFOHHosts)
        playerFacing.append(orbo.frontOfHouse)

        let layout = try orbo.advanceAstrosphereIntroduction()
        XCTAssertEqual(layout.progress, .layoutIntroduction)
        XCTAssertEqual(orbo.frontOfHouse, .introducingAstrosphere)
        XCTAssertEqual(orbo.backOfHouse, .nativeReady)
        playerFacing.append(layout)

        var bigThreeBeat = try orbo.beginBigThree(with: OrboPipelineFixture.bigThreeTruth)
        XCTAssertEqual(bigThreeBeat.progress, .moment)
        playerFacing.append(bigThreeBeat)

        bigThreeBeat = try orbo.advanceBigThree()
        XCTAssertEqual(bigThreeBeat.progress, .ascendant)
        XCTAssertEqual(bigThreeBeat.orboLines, ["When you were born, Gemini was on the horizon."])
        playerFacing.append(bigThreeBeat)

        bigThreeBeat = try orbo.advanceBigThree()
        XCTAssertEqual(bigThreeBeat.progress, .moon)
        XCTAssertEqual(bigThreeBeat.orboLines, ["When you were born, the Moon was in Leo."])
        playerFacing.append(bigThreeBeat)

        bigThreeBeat = try orbo.advanceBigThree()
        XCTAssertEqual(bigThreeBeat.progress, .sun)
        XCTAssertEqual(bigThreeBeat.orboLines, ["When you were born, the Sun was in Pisces."])
        playerFacing.append(bigThreeBeat)

        bigThreeBeat = try orbo.advanceBigThree()
        XCTAssertEqual(bigThreeBeat.progress, .bigThree)
        playerFacing.append(bigThreeBeat)

        bigThreeBeat = try orbo.advanceBigThree()
        XCTAssertEqual(bigThreeBeat.progress, .focus)
        playerFacing.append(bigThreeBeat)

        bigThreeBeat = try orbo.advanceBigThree()
        XCTAssertEqual(bigThreeBeat.progress, .tourChoice)
        playerFacing.append(bigThreeBeat)

        bigThreeBeat = try orbo.respondToBigThreeTour(.yesPlease)
        XCTAssertEqual(bigThreeBeat.progress, .complete)
        XCTAssertEqual(bigThreeBeat.orboLines, ["The astrosphere awaits!"])
        XCTAssertEqual(orbo.frontOfHouse, .ready)
        XCTAssertEqual(orbo.backOfHouse, .nativeReady)
        XCTAssertEqual(orbo.engravingTicketID, ticketID)
        XCTAssertEqual(orbo.engravingCommission, package)
        XCTAssertEqual(hermes.manifest.events(for: ticketID), manifestWhileFOHHosts)
        playerFacing.append(bigThreeBeat)
        playerFacing.append(orbo.frontOfHouse)

        assertPlayerFacingStateIsBackstageFree(playerFacing)
    }

    private func assertPlayerFacingStateIsBackstageFree(
        _ values: [Any],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let forbidden = [
            "HermesTicketID",
            "Atlas",
            "Moirai",
            "Clotho",
            "Chronos",
            "Horae",
            "Lachesis",
            "Titan",
            "ThemisPass",
            "RheaPass",
            "OceanusPass",
            "AsteriaPass",
            "Atropos",
            "Hestia",
            "Hearth",
            "Hephaestus",
        ]

        for value in values {
            let rendered = String(reflecting: value)
            for marker in forbidden {
                XCTAssertFalse(
                    rendered.contains(marker),
                    "Player-facing state leaked backstage marker \(marker): \(rendered)",
                    file: file,
                    line: line
                )
            }
        }
    }
}
