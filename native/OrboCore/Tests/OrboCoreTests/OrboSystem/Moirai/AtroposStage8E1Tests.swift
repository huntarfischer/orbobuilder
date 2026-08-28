import XCTest
@testable import OrboCore

final class AtroposStage8E1Tests: XCTestCase {
    func testAtroposSealsExactFinishedTapestry() throws {
        let work = try completedWork()

        let package = try Atropos.inspect(
            packet: work.packet,
            titanPass: work.titanPass,
            tapestry: work.tapestry
        ).get()

        XCTAssertEqual(package.tapestry, work.tapestry)
    }

    func testAtroposReportsPlacementMismatchAtExactDegree() throws {
        let work = try completedWork()
        let target = try XCTUnwrap(work.tapestry.degrees.first { !$0.placement.isEmpty })
        var degrees = work.tapestry.degrees
        let values = Array(target.placement.values.dropFirst())
        degrees[target.address.rawValue] = replacing(
            target,
            placement: TapestryPlacement(values: values)
        )
        let corrupted = Tapestry(allottedDegrees: degrees)

        XCTAssertEqual(
            Atropos.inspect(
                packet: work.packet,
                titanPass: work.titanPass,
                tapestry: corrupted
            ),
            .failure(.placementMismatch(degree: target.address))
        )
    }

    func testAtroposReportsTympanMismatchAtExactDegree() throws {
        let work = try completedWork()
        let target = work.tapestry.degrees[0]
        var degrees = work.tapestry.degrees
        degrees[0] = replacing(target, tympan: TapestryTympan())
        let corrupted = Tapestry(allottedDegrees: degrees)

        XCTAssertEqual(
            Atropos.inspect(
                packet: work.packet,
                titanPass: work.titanPass,
                tapestry: corrupted
            ),
            .failure(.tympanMismatch(degree: target.address))
        )
    }

    func testAtroposReportsMaterMismatchAtExactDegree() throws {
        let work = try completedWork()
        let target = try XCTUnwrap(work.tapestry.degrees.first { !$0.mater.isEmpty })
        var degrees = work.tapestry.degrees
        degrees[target.address.rawValue] = replacing(target, mater: TapestryMater())
        let corrupted = Tapestry(allottedDegrees: degrees)

        XCTAssertEqual(
            Atropos.inspect(
                packet: work.packet,
                titanPass: work.titanPass,
                tapestry: corrupted
            ),
            .failure(.materMismatch(degree: target.address))
        )
    }

    func testAtroposReportsRingMismatchAtExactDegree() throws {
        let work = try completedWork()
        let target = try XCTUnwrap(work.tapestry.degrees.first { !$0.ring.isEmpty })
        var degrees = work.tapestry.degrees
        degrees[target.address.rawValue] = replacing(target, ring: TapestryRing())
        let corrupted = Tapestry(allottedDegrees: degrees)

        XCTAssertEqual(
            Atropos.inspect(
                packet: work.packet,
                titanPass: work.titanPass,
                tapestry: corrupted
            ),
            .failure(.ringMismatch(degree: target.address))
        )
    }

    func testAtroposReportsArcMismatchAtExactDegree() throws {
        let work = try completedWork()
        let target = work.tapestry.degrees[0]
        let values = Array(target.arc.values.dropFirst())
        var degrees = work.tapestry.degrees
        degrees[0] = replacing(target, arc: TapestryArc(values: values))
        let corrupted = Tapestry(allottedDegrees: degrees)

        XCTAssertEqual(
            Atropos.inspect(
                packet: work.packet,
                titanPass: work.titanPass,
                tapestry: corrupted
            ),
            .failure(.arcMismatch(degree: target.address))
        )
    }

    private func completedWork() throws -> (
        packet: PatternPacket,
        titanPass: LachesisTitanPass,
        tapestry: Tapestry
    ) {
        let packet = try makePacket()
        let titanPass = Lachesis.petition(packet)
        let placement = Lachesis.allot(packet, into: Tapestry())
        let tapestry = Lachesis.allot(titanPass, into: placement)
        return (packet, titanPass, tapestry)
    }

    private func replacing(
        _ degree: TapestryDegree,
        placement: TapestryPlacement? = nil,
        tympan: TapestryTympan? = nil,
        mater: TapestryMater? = nil,
        ring: TapestryRing? = nil,
        arc: TapestryArc? = nil
    ) -> TapestryDegree {
        TapestryDegree(
            address: degree.address,
            placement: placement ?? degree.placement,
            tympan: tympan ?? degree.tympan,
            mater: mater ?? degree.mater,
            ring: ring ?? degree.ring,
            arc: arc ?? degree.arc
        )
    }

    private func makePacket() throws -> PatternPacket {
        PatternPacket(
            pattern: .engraving,
            astroDNA: try makeSyntheticDNA(),
            sect: .day,
            fortune: try XCTUnwrap(CelestialLongitude(215.25)),
            spirit: try XCTUnwrap(CelestialLongitude(198.5)),
            eros: try XCTUnwrap(CelestialLongitude(301.75)),
            necessity: try XCTUnwrap(CelestialLongitude(87.125))
        )
    }

    private func makeSyntheticDNA() throws -> AstroDNA {
        let sequence: [RingFineState] = [
            try state(215, 10, 0),
            try state(280, 5, 11),
            try state(15, 20, 22),
            try state(42, 11, 33, retrograde: true),
            try state(73, 22, 44),
            try state(101, 33, 55),
            try state(134, 44, 6, retrograde: true),
            try state(166, 55, 17),
            try state(199, 6, 28, retrograde: true),
            try state(231, 17, 39),
            try state(264, 28, 50, retrograde: true),
            try state(307, 39, 1, retrograde: true),
        ]

        return try XCTUnwrap(AstroDNA(sequence: sequence))
    }

    private func state(
        _ degree: Int,
        _ minute: Int,
        _ second: Int,
        retrograde: Bool = false
    ) throws -> RingFineState {
        let arcsecond = degree * Ring.arcsecondsPerDegree + minute * 60 + second
        let raw = retrograde ? Ring.arcseconds + arcsecond : arcsecond
        return try XCTUnwrap(RingFineState(raw))
    }
}
