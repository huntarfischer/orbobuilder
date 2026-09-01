import XCTest
@testable import OrboCore

final class SynchronicSpineActIIntegrationTests: XCTestCase {
    func testCompleteActIRelayEndsWithCertifiedSchematicAndHermesPickup() throws {
        let subject = HermesSubjectID(rawValue: "native-act-i-integration")!
        let natal = instant(year: 2001, month: 6, day: 15, hour: 12)
        var starter = SynchronicSpineActIStarter()

        // Beats 1-2: Hermes commissions Clotho; Clotho creates Pattern + true
        // Gregorian 101-year Bone and Lachesis receives the foundation.
        let foundation = try starter.start(subjectID: subject, natal: natal, occurredAt: natal)
        XCTAssertEqual(foundation.bone.start, instant(year: 2000, month: 6, day: 15, hour: 12))
        XCTAssertEqual(foundation.bone.end, instant(year: 2101, month: 6, day: 15, hour: 12))

        let locate = try makeLawfulMundaneSpineCovering(foundation.bone)
        let dna = try XCTUnwrap(AstroDNA(rawSequence: Array(repeating: 0, count: AstroDNA.geneCount)))

        // Beats 3-6: Lachesis gathers the four finished Titan fields.
        let asteria = try Lachesis.callAsteriaForSynchronicSpine(
            foundation: foundation,
            natalAstroDNA: dna,
            mundaneSpine: locate
        )
        let themis = Lachesis.callThemisForSynchronicSpine(
            foundation: foundation,
            natalAstroDNA: dna
        )
        let oceanus = Lachesis.callOceanusForSynchronicSpine(
            foundation: foundation,
            asteria: asteria
        )
        let rhea = Lachesis.callRheaForSynchronicSpine(
            foundation: foundation,
            asteria: asteria
        )

        // Beat 7: exact finished Pattern contents pass from Lachesis to Atropos.
        let contents = try Lachesis.holdSynchronicSpinePatternContents(
            foundation: foundation,
            asteria: asteria,
            themis: themis,
            oceanus: oceanus,
            rhea: rhea
        )

        XCTAssertEqual(contents.boneCount, 1)
        XCTAssertEqual(contents.asteriaPassCount, 12)
        XCTAssertEqual(contents.themisImprintCount, 7)
        XCTAssertEqual(contents.oceanusTideCount, 3)
        XCTAssertEqual(contents.rheaQualifierCount, 12)

        let schematic: CertifiedSynchronicSpineSchematic
        switch Atropos.certifySynchronicSpine(contents) {
        case .success(let value): schematic = value
        case .failure(let failure):
            XCTFail("Atropos rejected lawful Act I contents: \(failure)")
            return
        }

        XCTAssertEqual(schematic.status, .fulfilled)
        XCTAssertEqual(schematic.contents.foundation.commission.subjectID, subject)
        XCTAssertEqual(schematic.contents.foundation.commission.ticketID, foundation.commission.ticketID)
        XCTAssertEqual(schematic.contents.foundation.bone, foundation.bone)
        XCTAssertEqual(schematic.contents.asteria.passes.map(\.body), SynchronicAsteriaBody.canonicalOrder)
        XCTAssertEqual(schematic.contents.themis.imprints.map(\.offset), SynchronicThemisField.canonicalOffsets)
        XCTAssertEqual(schematic.contents.oceanus.tides.map(\.identity), SynchronicOceanusTideIdentity.canonicalOrder)
        XCTAssertEqual(schematic.contents.rhea.qualifiers.map(\.body), SynchronicAsteriaBody.canonicalOrder)

        // Beat 8: Atropos calls Hermes. Hermes recovers the original package
        // into custody; Hephaestus delivery belongs to Act II and must not occur.
        let reference = try Atropos.callHermesForCertifiedSynchronicSpine(
            schematic,
            courier: &starter.courier,
            occurredAt: foundation.bone.natal
        )
        let events = starter.courier.manifest.events(for: foundation.commission.ticketID)

        XCTAssertEqual(reference.certificationID, schematic.certificationID)
        XCTAssertEqual(reference.subjectID, subject)
        XCTAssertEqual(reference.ticketID, foundation.commission.ticketID)
        XCTAssertEqual(events.map(\.kind), [.ticketOpened, .deliveredToStop, .recoveredFromStop])
        XCTAssertEqual(events.last?.address, SynchronicSpineActIStarter.clotho)
        XCTAssertFalse(events.contains { $0.address == SynchronicSpineActIStarter.hephaestus })
        XCTAssertEqual(starter.courier.manifest.currentState(for: foundation.commission.ticketID), .unresolved)
    }

    private func makeLawfulMundaneSpineCovering(
        _ synchronicBone: SynchronicSpineBone
    ) throws -> OrboSpineLocate {
        let sourceStart = try XCTUnwrap(JulianDay(synchronicBone.start.julianDay.value - 1))
        let sourceEnd = try XCTUnwrap(JulianDay(synchronicBone.end.julianDay.value + 1))
        let sourceLast = try XCTUnwrap(JulianDay(sourceEnd.value - 1e-6))
        let sourceBone = try XCTUnwrap(OrboSpineBoneSpan(start: sourceStart, end: sourceEnd))

        // Synthetic fixture astronomy is intentionally boring but lawful: each
        // tract advances only 0.05° between supports, below the strictest
        // OrboSpine support step, across the entire source Bone.
        let intervalCount = 2048
        var supports: [OrboSpineCelestialCoordinate] = []
        supports.reserveCapacity(MundaneBody.canonicalOrder.count * (intervalCount + 1))

        for (bodyIndex, body) in MundaneBody.canonicalOrder.enumerated() {
            let base = Double(bodyIndex * 20 + 5)
            for index in 0...intervalCount {
                let fraction = Double(index) / Double(intervalCount)
                let jdValue = sourceBone.start.value + (sourceLast.value - sourceBone.start.value) * fraction
                let jd = try XCTUnwrap(JulianDay(jdValue))
                let degrees = normalized(base + Double(index) * 0.05)
                supports.append(coordinate(body, degrees, jd))
            }
        }

        var terra: [TerraMarrowSample] = [
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 0,
                tiltDegrees: 23.4,
                julianDay: sourceBone.start
            ))
        ]
        for seam in TerraMarrowContract.sourceModelSeamJulianDays
        where seam > sourceBone.start.value && seam < sourceBone.end.value {
            terra.append(try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 180,
                tiltDegrees: 23.4,
                julianDay: JulianDay(seam)!
            )))
        }
        terra.append(try XCTUnwrap(TerraMarrowSample(
            turnDegrees: 359.9,
            tiltDegrees: 23.4,
            julianDay: sourceBone.end
        )))

        return try XCTUnwrap(OrboSpineLocate(
            bone: sourceBone,
            celestialSupports: supports,
            terraSamples: terra
        ))
    }

    private func coordinate(
        _ body: MundaneBody,
        _ degrees: Double,
        _ julianDay: JulianDay
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: degrees,
                motion: .direct
            )!,
            julianDay: julianDay
        )
    }

    private func normalized(_ degrees: Double) -> Double {
        let remainder = degrees.truncatingRemainder(dividingBy: 360)
        return remainder < 0 ? remainder + 360 : remainder
    }

    private func instant(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0
    ) -> AbsoluteInstant {
        let date = CivilDate(year: year, month: month, day: day)!
        let time = CivilClockTime(hour: hour, minute: minute, second: 0)!
        let offset = UTCOffset(secondsEast: 0)!
        switch CivilTime.resolve(date: date, time: time, fixedOffset: offset) {
        case .resolved(let match): return match.instant
        default:
            XCTFail("Expected resolvable UTC instant")
            return AbsoluteInstant(unixSecondsSince1970: 0)!
        }
    }
}
