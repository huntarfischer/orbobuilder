public struct NatalSpineForgedRheaQualification: Hashable, Sendable {
    public let sourceRow: Int
    public let qualification: NatalSpineMaterQualification

    public init?(
        sourceRow: Int,
        qualification: NatalSpineMaterQualification
    ) {
        guard sourceRow >= 0 else { return nil }
        self.sourceRow = sourceRow
        self.qualification = qualification
    }
}

public struct NatalSpineRheaForgeLayer: Hashable, Sendable {
    public let commission: NatalSpineForgeCommission
    public let substrate: NatalSpineCelestialSubstrate
    public let themis: [NatalSpineForgedThemisSpan]
    public let oceanus: [NatalSpineForgedOceanusRealization]
    public let rhea: [NatalSpineForgedRheaQualification]

    fileprivate init(
        commission: NatalSpineForgeCommission,
        substrate: NatalSpineCelestialSubstrate,
        themis: [NatalSpineForgedThemisSpan],
        oceanus: [NatalSpineForgedOceanusRealization],
        rhea: [NatalSpineForgedRheaQualification]
    ) {
        self.commission = commission
        self.substrate = substrate
        self.themis = themis
        self.oceanus = oceanus
        self.rhea = rhea
    }

    public var subjectID: HermesSubjectID { commission.subjectID }
    public var bounds: NatalSpineBounds { commission.schematics.bounds }
}

public enum NatalSpineRheaForgeFailure: Error, Hashable, Sendable {
    case sourceMismatch
}

public extension Hephaestus {
    /// Transcribes Atropos-certified Rhea testimony independently.
    /// No Themis or Oceanus lookup, attachment, or reinterpretation occurs here.
    static func forgeNatalSpineRhea(
        on layer: NatalSpineOceanusForgeLayer
    ) throws -> NatalSpineRheaForgeLayer {
        let table = layer.commission.schematics.rhea
        let source = table.qualifications
        guard source.count == table.declaredCount else {
            throw NatalSpineRheaForgeFailure.sourceMismatch
        }

        let forged = source.enumerated().compactMap { index, qualification in
            NatalSpineForgedRheaQualification(
                sourceRow: index,
                qualification: qualification
            )
        }
        guard forged.count == source.count,
              forged.enumerated().allSatisfy({ index, value in
                  value.sourceRow == index && value.qualification == source[index]
              }) else {
            throw NatalSpineRheaForgeFailure.sourceMismatch
        }

        return NatalSpineRheaForgeLayer(
            commission: layer.commission,
            substrate: layer.substrate,
            themis: layer.themis,
            oceanus: layer.oceanus,
            rhea: forged
        )
    }
}
