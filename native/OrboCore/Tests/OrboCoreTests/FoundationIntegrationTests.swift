import XCTest
@testable import OrboCore

final class FoundationIntegrationTests: XCTestCase {
    func testRingMaterAndTympanComposeOnOneCanonicalAddress() throws {
        let body = try XCTUnwrap(CelestialLongitude(70))
        let ascendant = try XCTUnwrap(CelestialLongitude(220))

        XCTAssertEqual(body.sign, .gemini)
        XCTAssertEqual(ascendant.sign, .scorpio)
        XCTAssertEqual(Tympan.house(of: body, ascendant: ascendant), .eighth)

        let condition = try XCTUnwrap(
            Mater.essentialCondition(of: .mars, at: body, sect: .day)
        )
        XCTAssertEqual(condition.dignities, [.face])
        XCTAssertFalse(condition.isPeregrine)

        let bodyState = Ring.state(of: body, motion: .direct)
        let ascendantState = Ring.state(of: ascendant, motion: .retrograde)
        XCTAssertEqual(Ring.relation(between: bodyState, and: ascendantState), .quincunx)
    }

    func testTympanConsumesCanonicalMaterWithoutModernContamination() {
        for rising in Sign.canonicalOrder {
            let frame = Tympan.frame(for: rising)
            for record in frame.houses {
                XCTAssertEqual(record.ruler, Mater.domicileRuler(of: record.sign))
            }
        }

        XCTAssertEqual(Mater.domicileRuler(of: .scorpio), .mars)
        XCTAssertEqual(Tympan.coRuler(of: .scorpio), .pluto)
        XCTAssertNil(Tympan.TraditionalGovernor(planet: .pluto))
    }

    func testFoundationCanonicalSurfacesRemainClosedAndComplete() {
        XCTAssertEqual(Sign.canonicalOrder.count, 12)
        XCTAssertEqual(House.canonicalOrder.count, 12)
        XCTAssertEqual(Planet.classicalSeven.count, 7)
        XCTAssertEqual(Ring.marks.count, 11)

        for rising in Sign.canonicalOrder {
            let frame = Tympan.frame(for: rising)
            XCTAssertEqual(frame.houses.count, 12)
            XCTAssertEqual(Set(frame.houses.map(\.house)), Set(House.canonicalOrder))
        }
    }

    func testP22CivicSerializationAuditsLexicalCellsWithoutInventedTolerance() {
        XCTAssertEqual(
            MundaneTimespineP22CivicSerialization.auditLaw,
            "lexical JD interval intersects integer-second cell"
        )

        // Exact-major row 49,648: the printed JD lies on a half-second serialization edge.
        XCTAssertTrue(MundaneTimespineP22CivicSerialization.isConsistent(
            julianDayText: "2400981.472553641070",
            civicOffsetSeconds: 1_239_355_569
        ))
        XCTAssertFalse(MundaneTimespineP22CivicSerialization.isConsistent(
            julianDayText: "2400981.472553641070",
            civicOffsetSeconds: 1_239_355_571
        ))

        // Exact-minor row 301,552 exposed the opposite binary-Double rounding edge.
        XCTAssertTrue(MundaneTimespineP22CivicSerialization.isConsistent(
            julianDayText: "2444864.801095307805",
            civicOffsetSeconds: 5_030_875_154
        ))
        XCTAssertFalse(MundaneTimespineP22CivicSerialization.isConsistent(
            julianDayText: "2444864.801095307805",
            civicOffsetSeconds: 5_030_875_156
        ))

        XCTAssertFalse(MundaneTimespineP22CivicSerialization.isConsistent(
            julianDayText: "not-a-julian-day",
            civicOffsetSeconds: 0
        ))
    }

    func testMotionTopologySecondStrikeUsesDirectCelestialReconstruction() throws {
        let storedBody = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .sun,
            ticksPerDegree: 1,
            markerBodies: [],
            occurrences: [
                .init(celestialTick: 10, civicOffsetSeconds: 100, sequenceDirection: .increasing, markerWholeDegrees: []),
                .init(celestialTick: 11, civicOffsetSeconds: 200, sequenceDirection: .increasing, markerWholeDegrees: []),
                .init(celestialTick: 12, civicOffsetSeconds: 300, sequenceDirection: .increasing, markerWholeDegrees: []),
            ],
            stations: [],
            retrogradePassages: []
        ))
        let storage = try XCTUnwrap(MundaneTimespineStorageImage(
            spanName: "direct-second-strike fixture",
            astronomicalSource: "deterministic XCTest matter",
            astronomicalSourceVersion: "1",
            supportedStart: try XCTUnwrap(JulianDay(1_000)),
            supportedEnd: try XCTUnwrap(JulianDay(1_001)),
            bodies: [storedBody],
            relationships: [],
            eclipses: []
        ))
        let endpointAddress = try XCTUnwrap(PolluxCelestialAddress(
            body: .sun,
            celestialTick: 12,
            ticksPerDegree: 1,
            markerFingerprint: []
        ))
        let endpoint = PolluxQuestion(
            celestialAddress: endpointAddress,
            expectedSequenceDirection: .increasing,
            handoff: PolluxCivicHandoff(candidateSHA256: "fixture", civicOffsetSeconds: 300)
        )

        let reconstructed = try XCTUnwrap(PolluxMotionTopologyDirectLookup.reconstruct(
            endpoint: endpoint,
            storage: storage
        ))

        XCTAssertEqual(
            Pollux.motionTopologySecondStrikeLookupLaw,
            "celestial endpoint -> indexed civic occurrence -> adjacent topology"
        )
        XCTAssertEqual(reconstructed.address.body, .sun)
        XCTAssertEqual(reconstructed.address.from.celestialTick, 11)
        XCTAssertEqual(reconstructed.address.to.celestialTick, 12)
        XCTAssertEqual(reconstructed.address.fromDirection, .increasing)
        XCTAssertEqual(reconstructed.address.toDirection, .increasing)
        XCTAssertTrue(reconstructed.address.stationsBetween.isEmpty)
        XCTAssertEqual(reconstructed.handoff.civicOffsetSeconds, 300)
    }

    func testRelationshipSecondStrikeUsesCompactCelestialIndex() throws {
        let storedBody = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .sun,
            ticksPerDegree: 1,
            markerBodies: [],
            occurrences: [
                .init(celestialTick: 10, civicOffsetSeconds: 100, sequenceDirection: .increasing, markerWholeDegrees: []),
                .init(celestialTick: 11, civicOffsetSeconds: 200, sequenceDirection: .increasing, markerWholeDegrees: []),
            ],
            stations: [],
            retrogradePassages: []
        ))
        let start = try XCTUnwrap(JulianDay(1_000))
        let event = try XCTUnwrap(MundaneTimespineRelationshipEvent(
            bodyA: .sun,
            bodyB: .moon,
            mark: .conjunction,
            orientation: .sameDegree,
            bodyACelestialTimeDegrees: 42.5,
            bodyBCelestialTimeDegrees: 42.5,
            julianDay: try XCTUnwrap(JulianDay(start.value + 500.0 / 86_400.0)),
            exactAspectResidualArcSeconds: 0
        ))
        let storage = try XCTUnwrap(MundaneTimespineStorageImage(
            spanName: "relationship-second-strike fixture",
            astronomicalSource: "deterministic XCTest matter",
            astronomicalSourceVersion: "1",
            supportedStart: start,
            supportedEnd: try XCTUnwrap(JulianDay(1_001)),
            bodies: [storedBody],
            relationships: [event],
            eclipses: []
        ))
        let address = PolluxRelationshipDirectLookup.address(for: event)
        let lookup = try PolluxRelationshipDirectLookup(
            candidateSHA256: "fixture",
            storage: storage
        )
        let question = try XCTUnwrap(lookup.question(for: address))

        XCTAssertEqual(
            Pollux.relationshipSecondStrikeLookupLaw,
            "qualified celestial relationship identity -> compact candidate index -> civic occurrence"
        )
        XCTAssertEqual(question.address, address)
        XCTAssertEqual(question.handoff.candidateSHA256, "fixture")
        XCTAssertEqual(question.handoff.civicOffsetSeconds, 500)
    }

    func testExactRelationshipGeometryMayRecurAtDifferentCivicOccurrences() throws {
        let storedBody = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .sun,
            ticksPerDegree: 1,
            markerBodies: [],
            occurrences: [
                .init(celestialTick: 10, civicOffsetSeconds: 100, sequenceDirection: .increasing, markerWholeDegrees: []),
                .init(celestialTick: 11, civicOffsetSeconds: 900, sequenceDirection: .increasing, markerWholeDegrees: []),
            ],
            stations: [],
            retrogradePassages: []
        ))
        let start = try XCTUnwrap(JulianDay(1_000))
        let firstEvent = try XCTUnwrap(MundaneTimespineRelationshipEvent(
            bodyA: .sun,
            bodyB: .moon,
            mark: .trine,
            orientation: .bodyAAhead,
            bodyACelestialTimeDegrees: 200.125,
            bodyBCelestialTimeDegrees: 80.125,
            julianDay: try XCTUnwrap(JulianDay(start.value + 400.0 / 86_400.0)),
            exactAspectResidualArcSeconds: 0
        ))
        let secondEvent = try XCTUnwrap(MundaneTimespineRelationshipEvent(
            bodyA: .sun,
            bodyB: .moon,
            mark: .trine,
            orientation: .bodyAAhead,
            bodyACelestialTimeDegrees: 200.125,
            bodyBCelestialTimeDegrees: 80.125,
            julianDay: try XCTUnwrap(JulianDay(start.value + 700.0 / 86_400.0)),
            exactAspectResidualArcSeconds: 0
        ))
        let storage = try XCTUnwrap(MundaneTimespineStorageImage(
            spanName: "relationship-recurrence fixture",
            astronomicalSource: "deterministic XCTest matter",
            astronomicalSourceVersion: "1",
            supportedStart: start,
            supportedEnd: try XCTUnwrap(JulianDay(1_001)),
            bodies: [storedBody],
            relationships: [firstEvent, secondEvent],
            eclipses: []
        ))

        var cursor = PolluxRelationshipQuestionCursor(
            candidateSHA256: "fixture",
            storage: storage
        )
        let first = try XCTUnwrap(try cursor.next())
        let second = try XCTUnwrap(try cursor.next())

        XCTAssertEqual(
            Pollux.relationshipRecurrenceIdentityLaw,
            "exact celestial geometry + recurrence ordinal / civic UT excluded"
        )
        XCTAssertEqual(first.address.recurrenceOrdinal, 0)
        XCTAssertEqual(second.address.recurrenceOrdinal, 1)
        XCTAssertEqual(first.address.bodyAMicrodegrees, second.address.bodyAMicrodegrees)
        XCTAssertEqual(first.address.bodyBMicrodegrees, second.address.bodyBMicrodegrees)
        XCTAssertEqual(first.handoff.civicOffsetSeconds, 400)
        XCTAssertEqual(second.handoff.civicOffsetSeconds, 700)

        let lookup = try PolluxRelationshipDirectLookup(
            candidateSHA256: "fixture",
            storage: storage
        )
        XCTAssertEqual(
            lookup.question(for: second.address)?.handoff.civicOffsetSeconds,
            700
        )
    }

    func testExactRelationshipDuplicateAtSameStoredSecondStillFailsClosed() throws {
        let storedBody = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .sun,
            ticksPerDegree: 1,
            markerBodies: [],
            occurrences: [
                .init(celestialTick: 10, civicOffsetSeconds: 100, sequenceDirection: .increasing, markerWholeDegrees: []),
                .init(celestialTick: 11, civicOffsetSeconds: 900, sequenceDirection: .increasing, markerWholeDegrees: []),
            ],
            stations: [],
            retrogradePassages: []
        ))
        let start = try XCTUnwrap(JulianDay(1_000))
        let jd = try XCTUnwrap(JulianDay(start.value + 500.0 / 86_400.0))
        let first = try XCTUnwrap(MundaneTimespineRelationshipEvent(
            bodyA: .sun,
            bodyB: .moon,
            mark: .square,
            orientation: .bodyAAhead,
            bodyACelestialTimeDegrees: 120,
            bodyBCelestialTimeDegrees: 30,
            julianDay: jd,
            exactAspectResidualArcSeconds: 0
        ))
        let second = try XCTUnwrap(MundaneTimespineRelationshipEvent(
            bodyA: .sun,
            bodyB: .moon,
            mark: .square,
            orientation: .bodyAAhead,
            bodyACelestialTimeDegrees: 120,
            bodyBCelestialTimeDegrees: 30,
            julianDay: jd,
            exactAspectResidualArcSeconds: 0
        ))
        let storage = try XCTUnwrap(MundaneTimespineStorageImage(
            spanName: "relationship-duplicate fixture",
            astronomicalSource: "deterministic XCTest matter",
            astronomicalSourceVersion: "1",
            supportedStart: start,
            supportedEnd: try XCTUnwrap(JulianDay(1_001)),
            bodies: [storedBody],
            relationships: [first, second],
            eclipses: []
        ))

        var cursor = PolluxRelationshipQuestionCursor(
            candidateSHA256: "fixture",
            storage: storage
        )
        _ = try XCTUnwrap(try cursor.next())
        XCTAssertThrowsError(try cursor.next()) { error in
            XCTAssertEqual(error as? PolluxError, .ambiguousRelationshipIdentity)
        }
        XCTAssertThrowsError(try PolluxRelationshipDirectLookup(
            candidateSHA256: "fixture",
            storage: storage
        )) { error in
            XCTAssertEqual(error as? PolluxError, .ambiguousRelationshipIdentity)
        }
    }

    func testStationSecondStrikeUsesCompactCelestialIndex() throws {
        let station = MundaneTimespineStoredStation(
            celestialMicrodegrees: 12_345_678,
            civicOffsetSeconds: 250,
            motionAfter: .retrograde
        )
        let storedBody = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .sun,
            ticksPerDegree: 1,
            markerBodies: [],
            occurrences: [
                .init(celestialTick: 10, civicOffsetSeconds: 100, sequenceDirection: .increasing, markerWholeDegrees: []),
                .init(celestialTick: 11, civicOffsetSeconds: 300, sequenceDirection: .decreasing, markerWholeDegrees: []),
            ],
            stations: [station],
            retrogradePassages: []
        ))
        let storage = try XCTUnwrap(MundaneTimespineStorageImage(
            spanName: "station-second-strike fixture",
            astronomicalSource: "deterministic XCTest matter",
            astronomicalSourceVersion: "1",
            supportedStart: try XCTUnwrap(JulianDay(1_000)),
            supportedEnd: try XCTUnwrap(JulianDay(1_001)),
            bodies: [storedBody],
            relationships: [],
            eclipses: []
        ))
        let address = PolluxStationDirectLookup.address(body: .sun, station: station)
        let lookup = try PolluxStationDirectLookup(candidateSHA256: "fixture", storage: storage)
        let question = try XCTUnwrap(lookup.question(for: address))

        XCTAssertEqual(
            Pollux.stationSecondStrikeLookupLaw,
            "celestial station identity -> compact candidate index -> civic occurrence"
        )
        XCTAssertEqual(question.address, address)
        XCTAssertEqual(question.handoff.candidateSHA256, "fixture")
        XCTAssertEqual(question.handoff.civicOffsetSeconds, 250)
    }

    func testEclipseSecondStrikeUsesCompactCelestialIndex() throws {
        let storedBody = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .sun,
            ticksPerDegree: 1,
            markerBodies: [],
            occurrences: [
                .init(celestialTick: 10, civicOffsetSeconds: 100, sequenceDirection: .increasing, markerWholeDegrees: []),
                .init(celestialTick: 11, civicOffsetSeconds: 700, sequenceDirection: .increasing, markerWholeDegrees: []),
            ],
            stations: [],
            retrogradePassages: []
        ))
        let start = try XCTUnwrap(JulianDay(1_000))
        let event = try XCTUnwrap(MundaneTimespineEclipseEvent(
            kind: .solar,
            type: .total,
            eclipseDegree: 42.5,
            julianDay: try XCTUnwrap(JulianDay(start.value + 600.0 / 86_400.0)),
            magnitude: 1.02,
            centrality: "central"
        ))
        let storage = try XCTUnwrap(MundaneTimespineStorageImage(
            spanName: "eclipse-second-strike fixture",
            astronomicalSource: "deterministic XCTest matter",
            astronomicalSourceVersion: "1",
            supportedStart: start,
            supportedEnd: try XCTUnwrap(JulianDay(1_001)),
            bodies: [storedBody],
            relationships: [],
            eclipses: [event]
        ))
        let address = PolluxEclipseDirectLookup.address(for: event)
        let lookup = try PolluxEclipseDirectLookup(candidateSHA256: "fixture", storage: storage)
        let question = try XCTUnwrap(lookup.question(for: address))

        XCTAssertEqual(
            Pollux.eclipseSecondStrikeLookupLaw,
            "celestial eclipse identity -> compact candidate index -> civic occurrence"
        )
        XCTAssertEqual(question.address, address)
        XCTAssertEqual(question.handoff.candidateSHA256, "fixture")
        XCTAssertEqual(question.handoff.civicOffsetSeconds, 600)
    }

    func testDioscuriSecondStrikeProgressContractIsExplicit() {
        let started = DioscuriCertificationProgress(
            phase: .exactRelationship,
            completed: 123,
            total: 456,
            activity: .secondStrikeStarted,
            detail: "Sun / Moon conjunction"
        )
        let completed = DioscuriCertificationProgress(
            phase: .exactRelationship,
            completed: 123,
            total: 456,
            activity: .secondStrikeCompleted,
            detail: "reproduced divergence / Sun / Moon conjunction"
        )

        XCTAssertEqual(
            Dioscuri.secondStrikeVisibilityLaw,
            "start / finish progress events with phase and question position"
        )
        XCTAssertEqual(started.activity, .secondStrikeStarted)
        XCTAssertEqual(completed.activity, .secondStrikeCompleted)
        XCTAssertEqual(started.completed, completed.completed)
        XCTAssertEqual(started.total, completed.total)
        XCTAssertNotNil(started.detail)
        XCTAssertNotNil(completed.detail)
    }

    func testCheckpointSeekCursorsBeginAtTheNextUntestedQuestion() throws {
        let storedBody = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .sun,
            ticksPerDegree: 1,
            markerBodies: [],
            occurrences: [
                .init(celestialTick: 10, civicOffsetSeconds: 100, sequenceDirection: .increasing, markerWholeDegrees: []),
                .init(celestialTick: 11, civicOffsetSeconds: 200, sequenceDirection: .increasing, markerWholeDegrees: []),
                .init(celestialTick: 12, civicOffsetSeconds: 300, sequenceDirection: .increasing, markerWholeDegrees: []),
            ],
            stations: [],
            retrogradePassages: []
        ))
        let start = try XCTUnwrap(JulianDay(1_000))
        let firstRelationship = try XCTUnwrap(MundaneTimespineRelationshipEvent(
            bodyA: .sun,
            bodyB: .moon,
            mark: .conjunction,
            orientation: .sameDegree,
            bodyACelestialTimeDegrees: 20,
            bodyBCelestialTimeDegrees: 20,
            julianDay: try XCTUnwrap(JulianDay(start.value + 400.0 / 86_400.0)),
            exactAspectResidualArcSeconds: 0
        ))
        let secondRelationship = try XCTUnwrap(MundaneTimespineRelationshipEvent(
            bodyA: .sun,
            bodyB: .moon,
            mark: .square,
            orientation: .bodyAAhead,
            bodyACelestialTimeDegrees: 120,
            bodyBCelestialTimeDegrees: 30,
            julianDay: try XCTUnwrap(JulianDay(start.value + 500.0 / 86_400.0)),
            exactAspectResidualArcSeconds: 0
        ))
        let storage = try XCTUnwrap(MundaneTimespineStorageImage(
            spanName: "checkpoint-seek fixture",
            astronomicalSource: "deterministic XCTest matter",
            astronomicalSourceVersion: "1",
            supportedStart: start,
            supportedEnd: try XCTUnwrap(JulianDay(1_001)),
            bodies: [storedBody],
            relationships: [firstRelationship, secondRelationship],
            eclipses: []
        ))

        let bodyIndex = try PolluxBodyIndex(storedBody: storedBody)
        var bodyCursor = PolluxQuestionCursor(
            candidateSHA256: "fixture",
            bodyIndexes: [bodyIndex],
            startingAt: 2
        )
        XCTAssertEqual(bodyCursor.next()?.celestialAddress.celestialTick, 12)
        XCTAssertNil(bodyCursor.next())

        var motionCursor = PolluxMotionTopologyCursor(
            candidateSHA256: "fixture",
            storage: storage,
            startingAt: 1
        )
        let motionQuestion = try XCTUnwrap(motionCursor.next())
        XCTAssertEqual(motionQuestion.address.from.celestialTick, 11)
        XCTAssertEqual(motionQuestion.address.to.celestialTick, 12)
        XCTAssertNil(motionCursor.next())

        var relationshipCursor = PolluxRelationshipQuestionCursor(
            candidateSHA256: "fixture",
            storage: storage
        )
        try relationshipCursor.seek(to: 1)
        let relationshipQuestion = try XCTUnwrap(try relationshipCursor.next())
        XCTAssertEqual(
            relationshipQuestion.address,
            PolluxRelationshipDirectLookup.address(for: secondRelationship)
        )
        XCTAssertNil(try relationshipCursor.next())
    }
}
