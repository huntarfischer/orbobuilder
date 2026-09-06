import Foundation
@testable import OrboCore

enum NatalSpineActIIFixture {
    static func forgeCommission() throws -> NatalSpineForgeCommission {
        let hestia = try NatalSpineTestFixture.litHestia()
        let truth = try hestia.natalSpineNativeTruth(for: NatalSpineTestFixture.subjectID)
        let bounds = try Clotho.boundNatalSpine(truth)
        let threads = makeThreads(subjectID: truth.subjectID, bounds: bounds)

        let split = JulianDay(bounds.bone.start.value + 10)!
        var spans: [NatalSpineHouseSpan] = []
        for body in MundaneBody.canonicalOrder {
            if body == .sun {
                spans.append(NatalSpineHouseSpan(
                    body: body,
                    house: House(rawValue: 1)!,
                    start: bounds.bone.start,
                    end: split
                )!)
                spans.append(NatalSpineHouseSpan(
                    body: body,
                    house: House(rawValue: 2)!,
                    start: split,
                    end: bounds.bone.end
                )!)
            } else {
                spans.append(NatalSpineHouseSpan(
                    body: body,
                    house: House(rawValue: 1)!,
                    start: bounds.bone.start,
                    end: bounds.bone.end
                )!)
            }
        }
        let themis = NatalSpineThemisTable(
            subjectID: truth.subjectID,
            bounds: bounds,
            spans: spans
        )

        let ringValue = truth.tapestry.tapestry.degrees.flatMap(\.ring.values).first!
        let eventDay = JulianDay(bounds.bone.start.value + 20)!
        let occurrence = OrboSpineCelestialCoordinate(
            body: .sun,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: Double(ringValue.targetArcsecond) / Double(Ring.arcsecondsPerDegree),
                motion: .direct
            )!,
            julianDay: eventDay
        )
        let realization = NatalSpineRingRealization(
            mundaneBody: .sun,
            natalGene: ringValue.gene,
            natalSource: ringValue.source,
            relation: ringValue.mark,
            targetArcsecond: ringValue.targetArcsecond,
            occurrence: occurrence
        )!
        let oceanus = NatalSpineOceanusTable(
            subjectID: truth.subjectID,
            bounds: bounds,
            bodies: MundaneBody.canonicalOrder.map { body in
                NatalSpineOceanusBodyTable(
                    body: body,
                    realizations: body == .sun ? [realization] : []
                )
            }
        )

        let longitudes = Dictionary(uniqueKeysWithValues: Planet.canonicalOrder.enumerated().map {
            index, planet in (planet, CelestialLongitude(Double(index * 27 + 3))!)
        })
        let field = Rhea.bear(longitudes, sect: truth.sect)
        let rhea = NatalSpineRheaTable(
            subjectID: truth.subjectID,
            bounds: bounds,
            qualifications: [
                NatalSpineMaterQualification(
                    source: NatalSpineRheaSource(body: .sun, julianDay: split)!,
                    temper: field.temper(for: .sun)
                )!,
                NatalSpineMaterQualification(
                    source: NatalSpineRheaSource(body: .sun, julianDay: eventDay)!,
                    temper: field.temper(for: .sun)
                )!,
            ]
        )

        let certified = try Atropos.inspectNatalSpineSchematics(
            threads: threads,
            themis: themis,
            oceanus: oceanus,
            rhea: rhea
        ).get()
        let package = HermesPackage(
            packageID: HermesPackageID(),
            subjectID: truth.subjectID,
            sender: OrboOnboarding.orboAddress,
            kind: NatalSpineCommission.packageKind,
            addresses: NatalSpineCommission.itinerary,
            contents: certified
        )!
        return try Hephaestus.receiveNatalSpineSchematics(package)
    }

    static func substrate(for commission: NatalSpineForgeCommission) -> NatalSpineCelestialSubstrate {
        commission.schematics.threads
    }

    private static func makeThreads(
        subjectID: HermesSubjectID,
        bounds: NatalSpineBounds
    ) -> NatalSpineThreads {
        let bone = bounds.bone
        let firstDay = JulianDay(bone.start.value + 1)!
        let secondDay = JulianDay(bone.end.value - 1)!
        var supports: [OrboSpineCelestialCoordinate] = []
        var anchors: [OrboSpineBoundaryAnchor] = []
        for body in MundaneBody.canonicalOrder {
            supports.append(OrboSpineCelestialCoordinate(
                body: body,
                directionalDegree: OrboSpineDirectionalDegree(
                    physicalDegrees: 10,
                    motion: .direct
                )!,
                julianDay: firstDay
            ))
            supports.append(OrboSpineCelestialCoordinate(
                body: body,
                directionalDegree: OrboSpineDirectionalDegree(
                    physicalDegrees: 20,
                    motion: .direct
                )!,
                julianDay: secondDay
            ))
            anchors.append(OrboSpineBoundaryAnchor(
                body: body,
                boundary: .start,
                julianDay: bone.start,
                physicalDegrees: 9,
                motion: .direct
            )!)
            anchors.append(OrboSpineBoundaryAnchor(
                body: body,
                boundary: .endExclusive,
                julianDay: bone.end,
                physicalDegrees: 21,
                motion: .direct
            )!)
        }
        return NatalSpineThreads(
            subjectID: subjectID,
            bounds: bounds,
            supports: supports,
            stations: [],
            boundaryAnchors: anchors,
            parentProvenance: OrboSpineRuntimeProvenance(
                candidateManifestSHA256: String(repeating: "b", count: 64),
                astronomicalAuthority: "canonical-parent",
                astronomicalSourceVersion: "fixture"
            )!
        )!
    }
}
