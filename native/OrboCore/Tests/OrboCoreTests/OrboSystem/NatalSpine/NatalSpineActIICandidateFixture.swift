import Foundation
@testable import OrboCore

extension NatalSpineActIIFixture {
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
