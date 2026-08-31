import Foundation
@testable import OrboCore

extension NatalSpineActIIFixture {
    /// Deterministic read-only parent Timespine used by Act II/III tests.
    /// It owns no Ephemeris or forge capability. Hephaestus must derive every
    /// child support, station, and boundary anchor from this parent exactly as
    /// production does from OrboSpineRuntime.
    struct ParentSource: NatalSpineForgeTimespineSource {
        let commission: NatalSpineForgeCommission
        let sourceBone: OrboSpineBoneSpan
        let sourceStations: [OrboSpineStation]
        let sourceProvenance: OrboSpineRuntimeProvenance

        init(
            commission: NatalSpineForgeCommission,
            sourceStations: [OrboSpineStation] = [],
            sourceProvenance: OrboSpineRuntimeProvenance? = nil,
            sourceBone: OrboSpineBoneSpan? = nil
        ) {
            self.commission = commission
            self.sourceStations = sourceStations
            self.sourceProvenance = sourceProvenance ?? OrboSpineRuntimeProvenance(
                candidateManifestSHA256: String(repeating: "d", count: 64),
                astronomicalAuthority: "canonical-parent",
                astronomicalSourceVersion: "verification-fixture"
            )!
            let bone = commission.schematics.bounds.bone
            self.sourceBone = sourceBone ?? OrboSpineBoneSpan(
                start: JulianDay(bone.start.value - 10)!,
                end: JulianDay(bone.end.value + 10)!
            )!
        }

        func coordinate(
            of body: MundaneBody,
            at julianDay: JulianDay
        ) throws -> OrboSpineCelestialCoordinate {
            let bone = commission.schematics.bounds.bone
            guard julianDay.value >= bone.start.value,
                  julianDay.value <= bone.end.value else {
                throw OrboSpineLocateError.outsideBone
            }

            let duration = bone.end.value - bone.start.value
            let fraction = (julianDay.value - bone.start.value) / duration
            let physical = normalize(phase(for: body) + 360.0 * fraction)
            return OrboSpineCelestialCoordinate(
                body: body,
                directionalDegree: OrboSpineDirectionalDegree(
                    physicalDegrees: physical,
                    motion: .direct
                )!,
                julianDay: julianDay
            )
        }

        func occurrences(
            of body: MundaneBody,
            at directionalDegree: OrboSpineDirectionalDegree
        ) throws -> [OrboSpineCelestialCoordinate] {
            guard directionalDegree.motion == .direct else { return [] }

            let bone = commission.schematics.bounds.bone
            let duration = bone.end.value - bone.start.value
            let distance = normalize(
                directionalDegree.physicalDegrees - phase(for: body)
            )
            let julianDay = JulianDay(
                bone.start.value + (distance / 360.0) * duration
            )!
            guard bone.contains(julianDay) else { return [] }

            return [
                OrboSpineCelestialCoordinate(
                    body: body,
                    directionalDegree: directionalDegree,
                    julianDay: julianDay
                )
            ]
        }

        private func phase(for body: MundaneBody) -> Double {
            guard let event = commission.schematics.oceanus.realizations.first,
                  event.mundaneBody == body else {
                return 0
            }

            let bone = commission.schematics.bounds.bone
            let duration = bone.end.value - bone.start.value
            let eventFraction = (event.occurrence.julianDay.value - bone.start.value) / duration
            return normalize(
                event.occurrence.directionalDegree.physicalDegrees
                    - 360.0 * eventFraction
            )
        }

        private func normalize(_ degrees: Double) -> Double {
            let value = degrees.truncatingRemainder(dividingBy: 360.0)
            return value >= 0 ? value : value + 360.0
        }
    }

    static func parentSource(
        for commission: NatalSpineForgeCommission,
        stations: [OrboSpineStation] = [],
        provenance: OrboSpineRuntimeProvenance? = nil,
        bone: OrboSpineBoneSpan? = nil
    ) -> ParentSource {
        ParentSource(
            commission: commission,
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
        for commission: NatalSpineForgeCommission
    ) -> NatalSpineCelestialSubstrate {
        let parent = parentSource(for: commission)
        return try! Hephaestus.forgeNatalSpineSubstrate(
            for: commission,
            from: parent
        )
    }
}
