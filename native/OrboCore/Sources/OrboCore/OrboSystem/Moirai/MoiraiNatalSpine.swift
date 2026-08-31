public enum MoiraiNatalSpineFailure: Error, Hashable, Sendable {
    case unexpectedPackage
}

public extension Moirai {
    /// Fulfills the Moirai stop of the one Natal Spine commission.
    /// The same Hermes envelope leaves with Atropos-certified three-table schematics.
    static func processNatalSpineSchematics<Port: NatalSpineTimespinePort>(
        _ package: HermesPackage<NatalSpineSchematicsRequest>,
        hearth hestia: Hestia,
        through port: Port
    ) throws -> HermesPackage<AtroposNatalSpineSchematicsPackage> {
        guard package.kind == NatalSpineCommission.packageKind,
              package.addresses == NatalSpineCommission.itinerary,
              package.subjectID == package.contents.subjectID else {
            throw MoiraiNatalSpineFailure.unexpectedPackage
        }

        let truth = try hestia.natalSpineNativeTruth(for: package.subjectID)
        let bounds = try Clotho.boundNatalSpine(truth)
        let tables = try Lachesis.petitionNatalSpine(
            native: truth,
            bounds: bounds,
            through: port
        )
        let certified = try Atropos.inspectNatalSpineSchematics(
            bounds: bounds,
            themis: tables.themis,
            oceanus: tables.oceanus,
            rhea: tables.rhea
        ).get()

        return HermesPackage(
            packageID: package.packageID,
            subjectID: package.subjectID,
            sender: package.sender,
            kind: package.kind,
            addresses: package.addresses,
            contents: certified
        )!
    }
}
