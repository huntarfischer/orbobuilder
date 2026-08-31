import Foundation
@testable import OrboCore

extension NatalSpineActIIFixture {
    struct ParentSource: NatalSpineForgeTimespineSource {
        let substrate: NatalSpineCelestialSubstrate
        let sourceBone: OrboSpineBoneSpan
        let sourceStations: [OrboSpineStation]
        let sourceProvenance: OrboSpineRuntimeProvenance

        init(
            substrate: NatalSpineCelestialSubstrate,
            sourceStations: [OrboSpineStation]? = nil,
            sourceProvenance: OrboSpineRuntimeProvenance? = nil,
            sourceBone: OrboSpineBoneSpan? = nil
        ) {
            self.substrate = substrate
            self.sourceStations = sourceStations ?? substrate.stations
            self.sourceProvenance = sourceProvenance ?? substrate.parentProvenance
            self.sourceBone = sourceBone ?? OrboSpineBoneSpan(
                start: JulianDay(substrate.bounds.bone.start.value - 10)!,
                end: JulianDay(substrate.bounds.bone.end.value + 10)!
            )!
        }

        func coordinate(
            of body: MundaneBody,
            at julianDay: JulianDay
        ) throws -> OrboSpineCelestialCoordinate {
            let epsilon = 1e-9
            let boundary: OrboSpineBoundary
            if abs(julianDay.value - substrate.bounds.bone.start.value) <= epsilon {
                boundary = .start
            } else if abs(julianDay.value - substrate.bounds.bone.end.value) <= epsilon {
                boundary = .endExclusive
            } else if let support = substrate.supports.first(where: {
                $0.body == body && abs($0.julianDay.value - julianDay.value) <= epsilon
            }) {
                return support
            } else {
                throw NatalSpineSubstrateFailure.missingCelestialMatter(body)
            }

            guard let anchor = substrate.boundaryAnchors.first(where: {
                $0.body == body && $0.boundary == boundary
            }) else {
                throw NatalSpineSubstrateFailure.invalidBoundaryAnchor(body)
            }
            return OrboSpineCelestialCoordinate(
                body: body,
                directionalDegree: OrboSpineDirectionalDegree(
                    physicalDegrees: anchor.physicalDegrees,
                    motion: anchor.motion
                )!,
                julianDay: julianDay
            )
        }

        func occurrences(
            of body: MundaneBody,
            at directionalDegree: OrboSpineDirectionalDegree
        ) throws -> [OrboSpineCelestialCoordinate] {
            substrate.supports.filter {
                $0.body == body && $0.directionalDegree == directionalDegree
            }
        }
    }

    static func parentSource(
        for substrate: NatalSpineCelestialSubstrate,
        stations: [OrboSpineStation]? = nil,
        provenance: OrboSpineRuntimeProvenance? = nil,
        bone: OrboSpineBoneSpan? = nil
    ) -> ParentSource {
        ParentSource(
            substrate: substrate,
            sourceStations: stations,
            sourceProvenance: provenance,
            sourceBone: bone
        )
    }

    static func addressableCandidate(
        for commission: NatalSpineForgeCommission? = nil
    ) throws -> NatalSpineCandidate {
        let commission = try commission ?? forgeCommission()
        let substrate = navigableSubstrate(for: commission)
        let themis = try Hephaestus.forgeNatalSpineThemis(for: commission, on: substrate)
        let oceanus = try Hephaestus.forgeNatalSpineOceanus(on: themis)
        let rhea = try Hephaestus.forgeNatalSpineRhea(on: oceanus)
        return try Hephaestus.forgeNatalSpineAddressability(on: rhea)
    }

    static func navigableSubstrate(
        for commission: NatalSpineForgeCommission,
        provenance: OrboSpineRuntimeProvenance? = nil
    ) -> NatalSpineCelestialSubstrate {
        let bone = commission.schematics.bounds.bone
        let event = commission.schematics.oceanus.realizations.first!
        let pivot = event.occurrence.julianDay
        let remaining = bone.end.value - pivot.value

        var supports: [OrboSpineCelestialCoordinate] = []
        var anchors: [OrboSpineBoundaryAnchor] = []

        for body in MundaneBody.canonicalOrder {
            let step = OrboSpineContract.supportDegrees(for: body)
            let count = Int((360.0 / step).rounded())
            let target = body == event.mundaneBody
                ? event.occurrence.directionalDegree.physicalDegrees
                : 0.0
            let before = normalize(target - step)

            supports.append(
                OrboSpineCelestialCoordinate(
                    body: body,
                    directionalDegree: OrboSpineDirectionalDegree(
                        physicalDegrees: before,
                        motion: .direct
                    )!,
                    julianDay: bone.start
                )
            )
            supports.append(
                OrboSpineCelestialCoordinate(
                    body: body,
                    directionalDegree: OrboSpineDirectionalDegree(
                        physicalDegrees: target,
                        motion: .direct
                    )!,
                    julianDay: pivot
                )
            )

            let totalSteps = count * 2
            for index in 1..<totalSteps {
                let fraction = Double(index) / Double(totalSteps)
                let day = JulianDay(pivot.value + remaining * fraction)!
                supports.append(
                    OrboSpineCelestialCoordinate(
                        body: body,
                        directionalDegree: OrboSpineDirectionalDegree(
                            physicalDegrees: normalize(target + Double(index) * step),
                            motion: .direct
                        )!,
                        julianDay: day
                    )
                )
            }

            anchors.append(
                OrboSpineBoundaryAnchor(
                    body: body,
                    boundary: .start,
                    julianDay: bone.start,
                    physicalDegrees: before,
                    motion: .direct
                )!
            )
            anchors.append(
                OrboSpineBoundaryAnchor(
                    body: body,
                    boundary: .endExclusive,
                    julianDay: bone.end,
                    physicalDegrees: target,
                    motion: .direct
                )!
            )
        }

        return NatalSpineCelestialSubstrate(
            subjectID: commission.subjectID,
            bounds: commission.schematics.bounds,
            supports: supports,
            stations: [],
            boundaryAnchors: anchors,
            parentProvenance: provenance ?? OrboSpineRuntimeProvenance(
                candidateManifestSHA256: String(repeating: "d", count: 64),
                astronomicalAuthority: "canonical-parent",
                astronomicalSourceVersion: "verification-fixture"
            )!
        )!
    }

    private static func normalize(_ degrees: Double) -> Double {
        let value = degrees.truncatingRemainder(dividingBy: 360.0)
        return value >= 0 ? value : value + 360.0
    }
}
