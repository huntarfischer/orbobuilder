public enum Hephaestus {}

public struct NatalSpineForgeCommission: Hashable, Sendable {
    public let packageID: HermesPackageID
    public let subjectID: HermesSubjectID
    public let schematics: AtroposNatalSpineSchematicsPackage

    fileprivate init(
        packageID: HermesPackageID,
        subjectID: HermesSubjectID,
        schematics: AtroposNatalSpineSchematicsPackage
    ) {
        self.packageID = packageID
        self.subjectID = subjectID
        self.schematics = schematics
    }
}

public enum NatalSpineHephaestusFailure: Error, Hashable, Sendable {
    case unexpectedPackage
    case subjectMismatch
    case invalidCertification
}

public extension Hephaestus {
    /// Receives only Atropos-certified Natal Spine schematics carried under the
    /// original commission envelope. The strong contents type is the first seal:
    /// an uncertified request cannot enter this function at all.
    static func receiveNatalSpineSchematics(
        _ package: HermesPackage<AtroposNatalSpineSchematicsPackage>
    ) throws -> NatalSpineForgeCommission {
        guard package.kind == NatalSpineCommission.packageKind,
              package.addresses == NatalSpineCommission.itinerary else {
            throw NatalSpineHephaestusFailure.unexpectedPackage
        }
        guard package.subjectID == package.contents.subjectID else {
            throw NatalSpineHephaestusFailure.subjectMismatch
        }

        let certified = try Atropos.inspectNatalSpineSchematics(
            bounds: package.contents.bounds,
            themis: package.contents.themis,
            oceanus: package.contents.oceanus,
            rhea: package.contents.rhea
        ).get()
        guard certified == package.contents else {
            throw NatalSpineHephaestusFailure.invalidCertification
        }

        return NatalSpineForgeCommission(
            packageID: package.packageID,
            subjectID: package.subjectID,
            schematics: package.contents
        )
    }
}
