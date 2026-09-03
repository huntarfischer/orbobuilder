import XCTest

/// Drives the installed app and its real sealed Spine through actual touches.
/// The launch argument supplies a real birth/moment; it does not drive UI actions.
final class AstrolabeInteractionTests: XCTestCase {
    @MainActor
    func testCrowdedNatalSelectionPaneSeatsAndLiveClock() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["--orbo-ui-proof"]
        app.launch()
        guard app.buttons["orbo.natal.Mercury"].waitForExistence(timeout: 480) else {
            capture("Repass-Startup-Failure", app)
            XCTFail(app.debugDescription)
            return
        }
        XCTAssertFalse(app.tabBars.firstMatch.exists)
        capture("Repass-Aegis", app)

        app.buttons["orbo.seats"].tap()
        XCTAssertTrue(app.staticTexts["THE PLATE"].exists)
        XCTAssertTrue(app.staticTexts["THE RETE"].exists)
        capture("Repass-Seats", app)
        app.buttons["orbo.seats"].tap()

        // Tap the same crowded part of the wheel twice and choose each neighbor.
        // Coordinates exercise hit testing, rather than invoking model callbacks.
        for name in ["Mercury", "Venus"] {
            let mark = app.buttons["orbo.natal.Mercury"]
            mark.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            let choice = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", name + " ·")).firstMatch
            XCTAssertTrue(choice.waitForExistence(timeout: 5))
            if name == "Mercury" { capture("Repass-Crowded", app) }
            choice.tap()
            XCTAssertTrue(app.staticTexts["orbo.pane.title"].waitForExistence(timeout: 5))
            XCTAssertEqual(app.staticTexts["orbo.pane.title"].label, "natal " + name)
            XCTAssertTrue(app.buttons["orbo.pane.row." + name].exists)
            capture("Repass-" + name, app)
            app.buttons["orbo.pane.close"].tap()
        }
        app.buttons["orbo.pane.open"].tap()
        XCTAssertEqual(app.staticTexts["orbo.pane.title"].label, "my natal chart")
        XCTAssertTrue(app.staticTexts["Ean Weslynn · night chart"].exists)
        let natalSun = app.buttons["orbo.pane.row.Sun"].label
        capture("Repass-Pane", app)
        app.buttons["orbo.pane.close"].tap()
        app.buttons["orbo.sky.Ascendant"].tap()
        XCTAssertEqual(app.staticTexts["orbo.pane.title"].label, "the sky · Ascendant")
        XCTAssertEqual(app.buttons["orbo.sky.Ascendant"].value as? String, "Selected")
        app.buttons["orbo.pane.close"].tap()
        app.buttons["orbo.menu"].tap()
        app.buttons["Hearth"].tap()
        XCTAssertTrue(app.buttons["See my natal chart"].waitForExistence(timeout: 5))
        app.buttons["See my natal chart"].tap()
        XCTAssertEqual(app.staticTexts["orbo.pane.title"].label, "my natal chart")
        app.buttons["orbo.live"].tap()
        let clock = app.buttons["orbo.clock"]
        let first = clock.label
        let advances = expectation(for: NSPredicate(format: "label != %@", first), evaluatedWith: clock)
        wait(for: [advances], timeout: 8)
        XCTAssertEqual(app.buttons["orbo.pane.row.Sun"].label, natalSun)
    }

    @MainActor
    private func capture(_ name: String, _ app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
