import XCTest
@testable import OrboCore

final class OrboStage1Tests: XCTestCase {
    func testKnownTimePathFollowsCanonicalScriptOrder() throws {
        var orbo = Orbo()
        let birthDate = CivilDate(year: 1985, month: 4, day: 10)!
        let birthTime = CivilClockTime(hour: 20, minute: 16)!

        var beat = orbo.beginOnboarding()
        XCTAssertEqual(orbo.frontOfHouse, .onboarding)
        XCTAssertEqual(orbo.backOfHouse, .idle)
        XCTAssertEqual(beat.progress, .requestingName)
        XCTAssertEqual(
            beat.orboLines,
            [
                "Welcome, traveler.",
                "My name is Orbo. What's yours?",
            ]
        )

        beat = try orbo.respondToOnboarding(.name("Traveler"))
        XCTAssertEqual(beat.progress, .requestingReadingDepth)
        XCTAssertEqual(
            beat.orboLines,
            [
                "Heya, Traveler. It's nice to meet you.",
                "I am your guide to the astrosphere-the cosmic dimension on top of your own.",
                "How interested are you in astrology?",
            ]
        )

        beat = try orbo.respondToOnboarding(.astrologyInterest(.veryInterested))
        XCTAssertEqual(beat.progress, .requestingBirthDate)
        XCTAssertEqual(
            beat.orboLines,
            [
                "Everyone has their place in the astrosphere. Let's find yours.",
                "What day were you born?",
            ]
        )

        beat = try orbo.respondToOnboarding(.birthDate(birthDate))
        XCTAssertEqual(beat.progress, .requestingBirthLocation)
        XCTAssertEqual(beat.orboLines, ["Where were you Born?"])

        beat = try orbo.respondToOnboarding(.birthLocation("Madison, WI"))
        XCTAssertEqual(beat.progress, .requestingBirthTimeKnowledge)
        XCTAssertEqual(beat.orboLines, ["Do you know what time you were born?"])

        beat = try orbo.respondToOnboarding(.birthTimeKnowledge(.known))
        XCTAssertEqual(beat.progress, .requestingBirthTime)

        beat = try orbo.respondToOnboarding(.birthTime(birthTime))
        XCTAssertEqual(beat.progress, .readyForEngraving)
        XCTAssertEqual(orbo.onboardingSession?.progress, .readyForEngraving)
        XCTAssertEqual(orbo.onboardingSession?.name, "Traveler")
        XCTAssertEqual(orbo.onboardingSession?.readingDepth, .l3)
        XCTAssertEqual(orbo.onboardingSession?.birthDate, birthDate)
        XCTAssertEqual(orbo.onboardingSession?.birthLocation, "Madison, WI")
        XCTAssertEqual(orbo.onboardingSession?.birthTimeKnowledge, .known)
        XCTAssertEqual(orbo.onboardingSession?.birthTime, birthTime)
        XCTAssertEqual(orbo.backOfHouse, .idle)
    }

    func testInterestChoicesMapExactlyToReadingDepth() throws {
        let cases: [(OrboAstrologyInterest, OrboReadingDepth)] = [
            (.notVery, .l1),
            (.interested, .l2),
            (.veryInterested, .l3),
        ]

        for (interest, expectedDepth) in cases {
            var session = OrboOnboardingSession()
            try session.respond(.name("Traveler"))
            try session.respond(.astrologyInterest(interest))

            XCTAssertEqual(session.readingDepth, expectedDepth)
            XCTAssertEqual(session.progress, .requestingBirthDate)
        }
    }

    func testUnknownBirthTimeEntersRectificationWithoutInventingTime() throws {
        var orbo = Orbo()

        _ = orbo.beginOnboarding()
        _ = try orbo.respondToOnboarding(.name("Traveler"))
        _ = try orbo.respondToOnboarding(.astrologyInterest(.interested))
        _ = try orbo.respondToOnboarding(.birthDate(CivilDate(year: 1985, month: 4, day: 10)!))
        _ = try orbo.respondToOnboarding(.birthLocation("Madison, WI"))
        let beat = try orbo.respondToOnboarding(.birthTimeKnowledge(.unknown))

        XCTAssertEqual(beat.progress, .rectificationRequired)
        XCTAssertEqual(beat.orboLines, ["Do you know what time of day?"])
        XCTAssertEqual(orbo.onboardingSession?.progress, .rectificationRequired)
        XCTAssertFalse(orbo.onboardingSession?.readyForEngraving ?? true)
        XCTAssertEqual(orbo.onboardingSession?.birthTimeKnowledge, .unknown)
        XCTAssertNil(orbo.onboardingSession?.birthTime)
        XCTAssertEqual(orbo.backOfHouse, .idle)
    }

    func testInvalidOrderCannotSkipTheScript() throws {
        var orbo = Orbo()
        _ = orbo.beginOnboarding()
        let date = CivilDate(year: 1985, month: 4, day: 10)!

        XCTAssertThrowsError(
            try orbo.respondToOnboarding(.birthDate(date))
        ) { error in
            XCTAssertEqual(error as? OrboOnboardingFailure, .unexpectedResponse)
        }

        XCTAssertEqual(orbo.onboardingSession?.progress, .requestingName)
        XCTAssertNil(orbo.onboardingSession?.birthDate)

        XCTAssertThrowsError(
            try orbo.respondToOnboarding(.name("   "))
        ) { error in
            XCTAssertEqual(error as? OrboOnboardingFailure, .invalidName)
        }

        XCTAssertEqual(orbo.onboardingSession?.progress, .requestingName)
    }

    func testReadingDepthPersistsThroughLaterOnboardingBeats() throws {
        var orbo = Orbo()

        _ = orbo.beginOnboarding()
        _ = try orbo.respondToOnboarding(.name("Traveler"))
        _ = try orbo.respondToOnboarding(.astrologyInterest(.notVery))
        XCTAssertEqual(orbo.onboardingSession?.readingDepth, .l1)

        _ = try orbo.respondToOnboarding(.birthDate(CivilDate(year: 1985, month: 4, day: 10)!))
        XCTAssertEqual(orbo.onboardingSession?.readingDepth, .l1)

        _ = try orbo.respondToOnboarding(.birthLocation("Madison, WI"))
        XCTAssertEqual(orbo.onboardingSession?.readingDepth, .l1)

        _ = try orbo.respondToOnboarding(.birthTimeKnowledge(.known))
        XCTAssertEqual(orbo.onboardingSession?.readingDepth, .l1)

        _ = try orbo.respondToOnboarding(.birthTime(CivilClockTime(hour: 20, minute: 16)!))
        XCTAssertEqual(orbo.onboardingSession?.readingDepth, .l1)
        XCTAssertTrue(orbo.onboardingSession?.readyForEngraving ?? false)
    }
}
