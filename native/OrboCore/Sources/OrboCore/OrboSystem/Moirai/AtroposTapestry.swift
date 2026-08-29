/// Atropos is the Moirai's quality-control and sealing authority.
public enum Atropos {}

/// Failure surfaced while Atropos compares Lachesis's finished Tapestry with
/// the independent testimony that was supplied to her.
///
/// Each failure names the exact subsection and degree where correspondence was
/// lost. Atropos does not repair, recalculate, or re-allot any testimony.
public enum AtroposTapestryFailure: Error, Hashable, Sendable {
    case nonCanonicalTapestry
    case placementMismatch(degree: DegreeAddress)
    case tympanMismatch(degree: DegreeAddress)
    case materMismatch(degree: DegreeAddress)
    case ringMismatch(degree: DegreeAddress)
    case arcMismatch(degree: DegreeAddress)
}

/// Atropos's seal around the exact canonical Tapestry she inspected.
public struct AtroposTapestryPackage: Hashable, Sendable {
    public let tapestry: Tapestry

    fileprivate init(tapestry: Tapestry) {
        self.tapestry = tapestry
    }
}

public extension Atropos {
    /// Inspects one finished Tapestry against Clotho's PatternPacket and the
    /// four independent Titan testimonies gathered by Lachesis.
    ///
    /// Inspection follows the same canonical order in which Lachesis allotted
    /// the work: Placement, Tympan, Mater, Ring, Arc. No source is recomputed.
    /// On success Atropos seals the exact Tapestry value she was handed.
    static func inspect(
        packet: PatternPacket,
        titanPass: LachesisTitanPass,
        tapestry: Tapestry
    ) -> Result<AtroposTapestryPackage, AtroposTapestryFailure> {
        guard tapestry.degrees.count == DegreeAddress.count,
              tapestry.degrees.map(\.address) == DegreeAddress.canonicalOrder else {
            return .failure(.nonCanonicalTapestry)
        }

        if let degree = firstPlacementMismatch(packet: packet, tapestry: tapestry) {
            return .failure(.placementMismatch(degree: degree))
        }

        if let degree = firstTympanMismatch(pass: titanPass.themis, tapestry: tapestry) {
            return .failure(.tympanMismatch(degree: degree))
        }

        if let degree = firstMaterMismatch(pass: titanPass.rhea, tapestry: tapestry) {
            return .failure(.materMismatch(degree: degree))
        }

        if let degree = firstRingMismatch(pass: titanPass.oceanus, tapestry: tapestry) {
            return .failure(.ringMismatch(degree: degree))
        }

        if let degree = firstArcMismatch(pass: titanPass.asteria, tapestry: tapestry) {
            return .failure(.arcMismatch(degree: degree))
        }

        return .success(AtroposTapestryPackage(tapestry: tapestry))
    }

    private static func firstPlacementMismatch(
        packet: PatternPacket,
        tapestry: Tapestry
    ) -> DegreeAddress? {
        var expected = AstroDNAGene.canonicalOrder.map { gene in
            TapestryPlacementValue.astroDNA(gene: gene, state: packet.astroDNA[gene])
        }
        expected.append(.fortune(packet.fortune))
        expected.append(.spirit(packet.spirit))
        expected.append(.eros(packet.eros))
        expected.append(.necessity(packet.necessity))

        let expectedByAddress = Dictionary(grouping: expected, by: \.degreeAddress)

        for degree in tapestry.degrees {
            if degree.placement.values != (expectedByAddress[degree.address] ?? []) {
                return degree.address
            }
        }
        return nil
    }

    private static func firstTympanMismatch(
        pass: ThemisPass,
        tapestry: Tapestry
    ) -> DegreeAddress? {
        let houseBySign = Dictionary(
            uniqueKeysWithValues: pass.imprint.houses.map { ($0.sign, $0.house) }
        )

        for degree in tapestry.degrees {
            let sign = Sign(rawValue: degree.address.rawValue / 30)!
            if degree.tympan.house != houseBySign[sign] {
                return degree.address
            }
        }
        return nil
    }

    private static func firstMaterMismatch(
        pass: RheaPass,
        tapestry: Tapestry
    ) -> DegreeAddress? {
        let expectedByAddress = Dictionary(
            grouping: pass.field.tempers,
            by: { condition in
                DegreeAddress(
                    rawValue: Int(condition.longitude.degrees.rounded(.down))
                )!
            }
        )

        for degree in tapestry.degrees {
            if degree.mater.conditions != (expectedByAddress[degree.address] ?? []) {
                return degree.address
            }
        }
        return nil
    }

    private static func firstRingMismatch(
        pass: OceanusPass,
        tapestry: Tapestry
    ) -> DegreeAddress? {
        let expected = pass.objectTemplates.flatMap { object in
            object.marks.map { mark in
                TapestryRingValue(
                    gene: object.gene,
                    source: object.source,
                    mark: mark.mark,
                    targetArcsecond: mark.targetArcsecond
                )
            }
        }
        let expectedByAddress = Dictionary(grouping: expected, by: \.degreeAddress)

        for degree in tapestry.degrees {
            if degree.ring.values != (expectedByAddress[degree.address] ?? []) {
                return degree.address
            }
        }
        return nil
    }

    private static func firstArcMismatch(
        pass: AsteriaPass,
        tapestry: Tapestry
    ) -> DegreeAddress? {
        guard pass.refractions.count == pass.projections.count else {
            return DegreeAddress.canonicalOrder[0]
        }

        for degree in tapestry.degrees {
            let expected = zip(pass.refractions, pass.projections).map { refraction, projection in
                TapestryArcValue(
                    subject: refraction.subject,
                    cell: projection.cells[degree.address.rawValue]
                )
            }

            if degree.arc.values != expected {
                return degree.address
            }
        }
        return nil
    }
}
