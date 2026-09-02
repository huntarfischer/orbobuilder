import Foundation
import XCTest
@testable import OrboCore

final class SynchronicSpinePassATests: XCTestCase {
    private let subject = NatalSpineTestFixture.subjectID
    private let now = AbsoluteInstant(unixSecondsSince1970: 1_777_100_000)!

    func testUnreadyOrboCannotOpenCommission() throws {
        let hearth = try NatalSpineTestFixture.litHestia()
        var courier = HermesCourier()
        XCTAssertThrowsError(try Orbo().commissionSynchronicSpine(
            subjectID: subject, hearth: hearth, via: &courier, occurredAt: now
        )) { XCTAssertEqual($0 as? SynchronicSpinePassAFailure, .nativeTruthUnavailable) }
        XCTAssertTrue(courier.manifest.unresolvedTickets().isEmpty)
    }

    func testUnlitHearthCannotOpenCommission() {
        var courier = HermesCourier()
        XCTAssertThrowsError(try readyOrbo().commissionSynchronicSpine(
            subjectID: subject, hearth: Hestia(nativeSubjectID: subject),
            via: &courier, occurredAt: now
        )) { XCTAssertEqual($0 as? SynchronicSpinePassAFailure, .nativeTruthUnavailable) }
        XCTAssertTrue(courier.manifest.unresolvedTickets().isEmpty)
    }

    func testWrongNativeCannotOpenCommission() throws {
        let hearth = try NatalSpineTestFixture.litHestia()
        var courier = HermesCourier()
        XCTAssertThrowsError(try readyOrbo().commissionSynchronicSpine(
            subjectID: HermesSubjectID(rawValue: "foreign-native")!, hearth: hearth,
            via: &courier, occurredAt: now
        )) { XCTAssertEqual($0 as? SynchronicSpinePassAFailure, .wrongSubject) }
        XCTAssertTrue(courier.manifest.unresolvedTickets().isEmpty)
    }

    func testOpeningUsesOneSynchronicTicketAndTimeGardenItinerary() throws {
        let context = try makeContext(delivered: false)
        let handle = context.handle
        XCTAssertEqual(handle.package.subjectID, subject)
        XCTAssertEqual(handle.package.contents.subjectID, subject)
        XCTAssertEqual(handle.package.sender, OrboOnboarding.orboAddress)
        XCTAssertEqual(handle.package.kind, SynchronicSpineCommission.packageKind)
        XCTAssertNotEqual(handle.package.kind, NatalSpineCommission.packageKind)
        XCTAssertEqual(handle.package.addresses, [
            NatalSpineCommission.moiraiAddress,
            NatalSpineCommission.hephaestusAddress,
            SynchronicSpineCommission.timeGardenAddress,
        ])
        XCTAssertEqual(context.courier.manifest.unresolvedTickets(), [handle.ticketID])
        XCTAssertEqual(context.courier.manifest.events(for: handle.ticketID).map(\.kind), [.ticketOpened])
    }

    func testSamePackageCannotOpenSecondCommission() throws {
        var context = try makeContext(delivered: false)
        XCTAssertThrowsError(try readyOrbo().commissionSynchronicSpine(
            subjectID: subject, hearth: context.hearth, via: &context.courier,
            occurredAt: now, packageID: context.handle.package.packageID
        )) { XCTAssertEqual($0 as? SynchronicSpinePassAFailure, .alreadyCommissioned) }
        XCTAssertEqual(context.courier.manifest.unresolvedTickets(), [context.handle.ticketID])
        XCTAssertEqual(context.courier.manifest.events(for: context.handle.ticketID).count, 1)
    }

    func testMoiraiRequiresActualHermesDeliveryBeforeClothoReceives() throws {
        let context = try makeContext(delivered: false)
        XCTAssertThrowsError(try prepare(context)) {
            XCTAssertEqual($0 as? SynchronicSpinePassAFailure, .commissionNotDeliveredToClotho)
        }
    }

    func testFullPassARelayPreservesNativeCommissionAndParentBinding() throws {
        let context = try makeContext()
        let nativeBefore = context.hearth.nativeEngraving()
        let inventoryBefore = context.parent.inventory
        let terraBefore = try context.parent.locate.terra(at: context.parent.bone.start)
        let foundation = try prepare(context)
        XCTAssertEqual(foundation.commission, context.handle)
        XCTAssertEqual(foundation.native, nativeBefore)
        XCTAssertEqual(foundation.native.astroDNA, nativeBefore?.astroDNA)
        XCTAssertEqual(foundation.native.sect, nativeBefore?.sect)
        XCTAssertEqual(foundation.native.tapestry, nativeBefore?.tapestry)
        XCTAssertEqual(foundation.pattern.subjectID, subject)
        XCTAssertEqual(foundation.pattern.packageID, context.handle.package.packageID)
        XCTAssertEqual(foundation.pattern.ticketID, context.handle.ticketID)
        XCTAssertEqual(foundation.pattern.bone, foundation.bone)
        XCTAssertEqual(foundation.bone.ticketID, context.handle.ticketID)
        XCTAssertEqual(foundation.bone.packageID, context.handle.package.packageID)
        XCTAssertEqual(foundation.parentBone, context.parent.bone)
        XCTAssertEqual(foundation.parentProvenance, context.parent.provenance)
        XCTAssertEqual(context.hearth.nativeEngraving(), nativeBefore)
        XCTAssertEqual(context.parent.inventory, inventoryBefore)
        XCTAssertEqual(try context.parent.locate.terra(at: context.parent.bone.start), terraBefore)
        let events = context.courier.manifest.events(for: context.handle.ticketID)
        XCTAssertEqual(events.map(\.kind), [.ticketOpened, .deliveredToStop])
        XCTAssertEqual(events.last?.address, SynchronicSpineCommission.moiraiAddress)
        XCTAssertEqual(context.courier.manifest.currentState(for: context.handle.ticketID), .unresolved)
    }

    func testClothoUsesExactGregorianAnniversariesAndOriginalBirthInstant() throws {
        let context = try makeContext()
        let foundation = try prepare(context)
        XCTAssertEqual(foundation.bone.start, instant(1989, 5, 17, 19, 32))
        XCTAssertEqual(foundation.bone.natal, instant(1990, 5, 17, 19, 32))
        XCTAssertEqual(foundation.bone.end, instant(2090, 5, 17, 19, 32))
        XCTAssertEqual(foundation.bone.natal, foundation.native.tempus?.absoluteInstant)
        let truth = try context.hearth.natalSpineNativeTruth(for: subject)
        XCTAssertEqual(foundation.bone.bounds, try Clotho.boundNatalSpine(truth))
    }

    func testLeapDayBirthKeepsEstablishedGregorianClampingLaw() throws {
        let hearth = try leapDayHearth()
        let foundation = try prepare(makeContext(hearth: hearth))
        XCTAssertEqual(foundation.bone.start, instant(1999, 2, 28, 20, 32))
        XCTAssertEqual(foundation.bone.natal, instant(2000, 2, 29, 20, 32))
        XCTAssertEqual(foundation.bone.end, instant(2100, 2, 28, 20, 32))
    }

    func testBoneIsHalfOpenIncludingWhenParentHasSameEnd() throws {
        let foundation = try prepare(makeContext())
        let bone = foundation.bone
        XCTAssertEqual(foundation.parentBone, bone.span)
        XCTAssertFalse(bone.contains(AbsoluteInstant(unixSecondsSince1970: bone.start.unixSecondsSince1970 - 1)!))
        XCTAssertTrue(bone.contains(bone.start))
        XCTAssertTrue(bone.contains(bone.natal))
        XCTAssertTrue(bone.contains(AbsoluteInstant(unixSecondsSince1970: bone.end.unixSecondsSince1970 - 1)!))
        XCTAssertFalse(bone.contains(bone.end))
        XCTAssertFalse(bone.span.contains(bone.end.julianDay))
    }

    func testPatternRequiresOneBoneAndExactlyThirtyFourTitanConstituents() throws {
        let pattern = try prepare(makeContext()).pattern
        let required = [1, 12, 7, 3, 12]
        func matches(_ counts: [Int]) -> Bool {
            pattern.matchesInventory(boneCount: counts[0], asteriaPassCount: counts[1],
                themisImprintCount: counts[2], oceanusTideCount: counts[3], rheaQualifierCount: counts[4])
        }
        XCTAssertTrue(matches(required))
        XCTAssertEqual(required.dropFirst().reduce(0, +), 34)
        XCTAssertFalse(matches([1, 0, 0, 0, 0]), "The Bone alone does not fulfill the Pattern")
        for index in required.indices {
            for delta in [-1, 1] {
                var altered = required
                altered[index] += delta
                XCTAssertFalse(matches(altered), "Off-by-one inventory admitted: \(altered)")
            }
        }
    }

    func testLachesisReceivesExactClothoFoundationWithoutAdvancingHermes() throws {
        let context = try makeContext()
        let cut = try Clotho.cutSynchronicSpineFoundation(
            commission: context.handle, hearth: context.hearth, parent: context.parent
        )
        XCTAssertEqual(try Lachesis.receiveSynchronicSpineFoundation(cut), cut)
        XCTAssertEqual(try prepare(context), cut)
        XCTAssertEqual(try prepare(context), try prepare(context))
        XCTAssertEqual(context.courier.manifest.events(for: context.handle.ticketID).count, 2)
    }

    func testWrongPurposeSenderItineraryAndRequestNativeAreRejected() throws {
        let context = try makeContext()
        let original = context.handle.package
        let foreign = HermesSubjectID(rawValue: "foreign-native")!
        let variants: [HermesPackage<SynchronicSpineSchematicsRequest>] = [
            package(original, kind: NatalSpineCommission.packageKind),
            package(original, sender: NatalSpineCommission.hephaestusAddress),
            package(original, addresses: NatalSpineCommission.itinerary),
            package(original, requestSubject: foreign),
        ]
        for altered in variants {
            let handle = SynchronicSpineCommissionHandle(package: altered, ticketID: context.handle.ticketID)
            XCTAssertThrowsError(try Moirai.prepareSynchronicSpine(
                handle, hearth: context.hearth, parent: context.parent, courier: context.courier
            )) { XCTAssertEqual($0 as? SynchronicSpinePassAFailure, .unexpectedPackage) }
        }
    }

    func testForeignTicketAndPackageCannotSubstituteForDeliveredCommission() throws {
        let context = try makeContext()
        let handles = [
            SynchronicSpineCommissionHandle(package: context.handle.package, ticketID: HermesTicketID()),
            SynchronicSpineCommissionHandle(package: SynchronicSpineCommission.package(subjectID: subject),
                                            ticketID: context.handle.ticketID),
        ]
        for handle in handles {
            XCTAssertThrowsError(try Moirai.prepareSynchronicSpine(
                handle, hearth: context.hearth, parent: context.parent, courier: context.courier
            )) { XCTAssertEqual($0 as? SynchronicSpinePassAFailure, .commissionNotDeliveredToClotho) }
        }
    }

    func testParentMustCoverBothBoneBoundaries() throws {
        let context = try makeContext()
        let span = context.parent.bone
        let tooShort = [
            OrboSpineBoneSpan(start: JulianDay(span.start.value + 1)!, end: span.end)!,
            OrboSpineBoneSpan(start: span.start, end: JulianDay(span.end.value - 1)!)!,
        ]
        for bone in tooShort {
            XCTAssertThrowsError(try Moirai.prepareSynchronicSpine(
                context.handle, hearth: context.hearth, parent: parent(on: bone), courier: context.courier
            )) { XCTAssertEqual($0 as? SynchronicSpinePassAFailure, .sourceDoesNotCoverBone) }
        }
        XCTAssertEqual(context.courier.manifest.currentState(for: context.handle.ticketID), .unresolved)
    }

    func testLachesisRejectsAlteredBoneAndForeignPattern() throws {
        let good = try prepare(makeContext())
        let changedBounds = NatalSpineBounds(subjectID: subject,
            start: AbsoluteInstant(unixSecondsSince1970: good.bone.start.unixSecondsSince1970 + 1)!,
            natal: good.bone.natal, end: good.bone.end)!
        let changedBone = SynchronicSpineBone(packageID: good.bone.packageID,
            ticketID: good.bone.ticketID, bounds: changedBounds)
        let foreignPattern = SynchronicSpinePattern(subjectID: subject,
            packageID: good.pattern.packageID, ticketID: HermesTicketID(), bone: good.bone)
        for (pattern, bone) in [(good.pattern, changedBone), (foreignPattern, good.bone)] {
            let altered = SynchronicSpineFoundation(commission: good.commission, pattern: pattern,
                bone: bone, native: good.native, parentBone: good.parentBone,
                parentProvenance: good.parentProvenance)
            XCTAssertThrowsError(try Lachesis.receiveSynchronicSpineFoundation(altered)) {
                XCTAssertEqual($0 as? SynchronicSpinePassAFailure, .mismatchedFoundation)
            }
        }
    }

    private struct Context {
        let hearth: Hestia
        let parent: OrboSpineRuntime
        let handle: SynchronicSpineCommissionHandle
        var courier: HermesCourier
    }

    private func readyOrbo() -> Orbo {
        var orbo = Orbo()
        orbo.transitionBackOfHouse(to: .nativeReady)
        return orbo
    }

    private func makeContext(hearth supplied: Hestia? = nil, delivered: Bool = true) throws -> Context {
        let hearth = try supplied ?? NatalSpineTestFixture.litHestia()
        let bounds = try Clotho.boundNatalSpine(hearth.natalSpineNativeTruth(for: subject))
        var courier = HermesCourier()
        let handle = try readyOrbo().commissionSynchronicSpine(
            subjectID: subject, hearth: hearth, via: &courier, occurredAt: now
        )
        if delivered {
            XCTAssertEqual(try courier.deliverNext(ticketID: handle.ticketID, occurredAt: now),
                           SynchronicSpineCommission.moiraiAddress)
        }
        return Context(hearth: hearth, parent: try parent(on: bounds.bone), handle: handle, courier: courier)
    }

    private func prepare(_ context: Context) throws -> SynchronicSpineFoundation {
        try Moirai.prepareSynchronicSpine(context.handle, hearth: context.hearth,
                                        parent: context.parent, courier: context.courier)
    }

    /// A deterministic parent assembly for extent/binding proof only. This is
    /// not astronomical materialization and earns no Pass B chronology claim.
    private func parent(on bone: OrboSpineBoneSpan) throws -> OrboSpineRuntime {
        let middle = JulianDay((bone.start.value + bone.end.value) / 2)!
        let supports = MundaneBody.canonicalOrder.flatMap { body in
            [OrboSpineCelestialCoordinate(body: body,
                directionalDegree: OrboSpineDirectionalDegree(10)!, julianDay: bone.start),
             OrboSpineCelestialCoordinate(body: body,
                directionalDegree: OrboSpineDirectionalDegree(10 + OrboSpineContract.supportDegrees(for: body) / 2)!,
                julianDay: middle)]
        }
        var days = [bone.start.value, bone.end.value]
        days += TerraMarrowContract.sourceModelSeamJulianDays.filter {
            $0 > bone.start.value && $0 < bone.end.value
        }.flatMap { [$0 - 0.25, $0, $0 + 0.25] }
        let terra = days.sorted().enumerated().map { index, day in
            TerraMarrowSample(turnDegrees: Double(index * 10), tiltDegrees: 23.44, julianDay: JulianDay(day)!)!
        }
        let shells = OrboSpineShellFamily.allCases.map { family in
            OrboSpineShellInterval(id: OrboSpineShellID(family: family, ordinal: 1)!,
                                  start: bone.start, end: bone.end)!
        }
        return try XCTUnwrap(OrboSpineRuntime(bone: bone, celestialSupports: supports,
            stations: [], retrogradePassages: [], ringOccurrences: [], eclipses: [],
            shellIntervals: shells, terraSamples: terra,
            provenance: OrboSpineRuntimeProvenance(candidateManifestSHA256: String(repeating: "a", count: 64),
                astronomicalAuthority: "Pass A fixture", astronomicalSourceVersion: "extent-only")!))
    }

    private func leapDayHearth() throws -> Hestia {
        let request = OrboOnboarding.complete(subjectID: subject, name: "Leap-day fixture",
            birthDate: CivilDate(year: 2000, month: 2, day: 29)!,
            birthTime: NatalSpineTestFixture.birthTime, birthLocation: NatalSpineTestFixture.birthLocation)
        guard case let .found(engraving) = Atlas().resolve(request.contents) else {
            throw NatalSpineTestFixture.Failure.atlasResolution
        }
        let resolved = HermesPackage(packageID: request.packageID, subjectID: request.subjectID,
            sender: request.sender, kind: request.kind, addresses: request.addresses, contents: engraving)!
        var port = NatalSpineTestFixture.PortIStub(output: try NatalSpineTestFixture.slice(for: engraving))
        let worked = try Moirai.process(resolved, through: &port)
        var hearth = Hestia(nativeSubjectID: subject)
        _ = try hearth.receive(worked)
        return hearth
    }

    private func instant(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int) -> AbsoluteInstant {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
        return AbsoluteInstant(unixSecondsSince1970: date.timeIntervalSince1970)!
    }

    private func package(_ original: HermesPackage<SynchronicSpineSchematicsRequest>,
                         kind: HermesPackageKind? = nil, sender: HermesAddress? = nil,
                         addresses: [HermesAddress]? = nil, requestSubject: HermesSubjectID? = nil)
        -> HermesPackage<SynchronicSpineSchematicsRequest> {
        HermesPackage(packageID: original.packageID, subjectID: original.subjectID,
            sender: sender ?? original.sender, kind: kind ?? original.kind,
            addresses: addresses ?? original.addresses,
            contents: SynchronicSpineSchematicsRequest(subjectID: requestSubject ?? subject))!
    }
}
