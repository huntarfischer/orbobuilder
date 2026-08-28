public extension Lachesis {
    /// Allots the four already-gathered Titan testimonies in Lachesis's fixed
    /// synchronous order. Each pass remains a separate immutable witness.
    static func allot(
        _ titanPass: LachesisTitanPass,
        into tapestry: Tapestry
    ) -> Tapestry {
        let afterThemis = allotThemis(titanPass.themis, into: tapestry)
        let afterRhea = allotRhea(titanPass.rhea, into: afterThemis)
        let afterOceanus = allotOceanus(titanPass.oceanus, into: afterRhea)
        return allotAsteria(titanPass.asteria, into: afterOceanus)
    }

    /// Stage 1: ThemisPass -> Tympan.
    ///
    /// Themis has already testified which whole-sign house belongs to each
    /// sign. Lachesis only addresses those twelve answers across 0...359.
    static func allotThemis(
        _ pass: ThemisPass,
        into tapestry: Tapestry
    ) -> Tapestry {
        requireCanonical(tapestry)
        precondition(tapestry.degrees.allSatisfy { $0.tympan.isEmpty })

        let houseBySign = Dictionary(
            uniqueKeysWithValues: pass.imprint.houses.map { record in
                (record.sign, record.house)
            }
        )

        let allottedDegrees = tapestry.degrees.map { degree in
            let sign = Sign(rawValue: degree.address.rawValue / 30)!
            let house = houseBySign[sign]!

            return TapestryDegree(
                address: degree.address,
                placement: degree.placement,
                tympan: TapestryTympan(house: house),
                mater: degree.mater,
                ring: degree.ring,
                arc: degree.arc
            )
        }

        return Tapestry(allottedDegrees: allottedDegrees)
    }

    /// Stage 2: RheaPass -> Mater.
    ///
    /// Every qualified planetary condition retains the exact longitude Rhea
    /// testified. Lachesis uses that longitude only as the Tapestry address.
    static func allotRhea(
        _ pass: RheaPass,
        into tapestry: Tapestry
    ) -> Tapestry {
        requireCanonical(tapestry)
        precondition(tapestry.degrees.allSatisfy { $0.mater.isEmpty })

        let conditionsByAddress = Dictionary(
            grouping: pass.field.tempers,
            by: { condition in
                DegreeAddress(
                    rawValue: Int(condition.longitude.degrees.rounded(.down))
                )!
            }
        )

        let allottedDegrees = tapestry.degrees.map { degree in
            TapestryDegree(
                address: degree.address,
                placement: degree.placement,
                tympan: degree.tympan,
                mater: TapestryMater(
                    conditions: conditionsByAddress[degree.address] ?? []
                ),
                ring: degree.ring,
                arc: degree.arc
            )
        }

        return Tapestry(allottedDegrees: allottedDegrees)
    }

    /// Stage 3: OceanusPass -> Ring.
    ///
    /// Lachesis allots Oceanus's exact marks to their testified target degrees.
    /// Source gene, exact source state, mark, and target arcsecond remain intact.
    static func allotOceanus(
        _ pass: OceanusPass,
        into tapestry: Tapestry
    ) -> Tapestry {
        requireCanonical(tapestry)
        precondition(tapestry.degrees.allSatisfy { $0.ring.isEmpty })

        let values = pass.objectTemplates.flatMap { object in
            object.marks.map { mark in
                TapestryRingValue(
                    gene: object.gene,
                    source: object.source,
                    mark: mark.mark,
                    targetArcsecond: mark.targetArcsecond
                )
            }
        }
        let valuesByAddress = Dictionary(grouping: values, by: \.degreeAddress)

        let allottedDegrees = tapestry.degrees.map { degree in
            TapestryDegree(
                address: degree.address,
                placement: degree.placement,
                tympan: degree.tympan,
                mater: degree.mater,
                ring: TapestryRing(
                    values: valuesByAddress[degree.address] ?? []
                ),
                arc: degree.arc
            )
        }

        return Tapestry(allottedDegrees: allottedDegrees)
    }

    /// Stage 4: AsteriaPass -> Arc.
    ///
    /// Each Asteria projection is independent and already spans all 360 degree
    /// windows. Lachesis places each testified ArcDegreeCell beside its subject;
    /// she does not recast or reinterpret Arc geometry.
    static func allotAsteria(
        _ pass: AsteriaPass,
        into tapestry: Tapestry
    ) -> Tapestry {
        requireCanonical(tapestry)
        precondition(tapestry.degrees.allSatisfy { $0.arc.isEmpty })
        precondition(pass.refractions.count == pass.projections.count)

        var valuesByAddress: [DegreeAddress: [TapestryArcValue]] = [:]

        for (refraction, projection) in zip(pass.refractions, pass.projections) {
            precondition(projection.field == refraction.field)
            precondition(projection.cells.count == DegreeAddress.count)

            for cell in projection.cells {
                let address = DegreeAddress(rawValue: cell.degree)!
                valuesByAddress[address, default: []].append(
                    TapestryArcValue(subject: refraction.subject, cell: cell)
                )
            }
        }

        let allottedDegrees = tapestry.degrees.map { degree in
            TapestryDegree(
                address: degree.address,
                placement: degree.placement,
                tympan: degree.tympan,
                mater: degree.mater,
                ring: degree.ring,
                arc: TapestryArc(
                    values: valuesByAddress[degree.address] ?? []
                )
            )
        }

        return Tapestry(allottedDegrees: allottedDegrees)
    }

    private static func requireCanonical(_ tapestry: Tapestry) {
        precondition(tapestry.degrees.count == DegreeAddress.count)
        precondition(tapestry.degrees.map(\.address) == DegreeAddress.canonicalOrder)
    }
}
