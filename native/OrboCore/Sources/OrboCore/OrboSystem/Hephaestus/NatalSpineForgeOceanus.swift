public struct NatalSpineForgedOceanusRealization: Hashable, Sendable {
    public let sourceRow: Int
    public let realization: NatalSpineRingRealization

    public init?(sourceRow: Int, realization: NatalSpineRingRealization) {
        guard sourceRow >= 0 else { return nil }
        self.sourceRow = sourceRow
        self.realization = realization
    }
}

public struct NatalSpineOceanusForgeLayer: Hashable, Sendable {
    public let commission: NatalSpineForgeCommission
    public let substrate: NatalSpineCelestialSubstrate
    public let themis: [NatalSpineForgedThemisSpan]
    public let oceanus: [NatalSpineForgedOceanusRealization]

    fileprivate init(
        commission: NatalSpineForgeCommission,
        substrate: NatalSpineCelestialSubstrate,
        themis: [NatalSpineForgedThemisSpan],
        oceanus: [NatalSpineForgedOceanusRealization]
    ) {
        self.commission = commission
        self.substrate = substrate
        self.themis = themis
        self.oceanus = oceanus
    }

    public var subjectID: HermesSubjectID { commission.subjectID }
    public var bounds: NatalSpineBounds { commission.schematics.bounds }
}

public enum NatalSpineOceanusForgeFailure: Error, Hashable, Sendable {
    case sourceMismatch
}

public extension Hephaestus {
    /// ACT II Beat 4. Admits every Atropos-certified Oceanus realization into the
    /// same child body that already carries the certified Themis spans.
    /// No Ring geometry or celestial timing is recomputed here.
    static func forgeNatalSpineOceanus(
        on layer: NatalSpineThemisForgeLayer
    ) throws -> NatalSpineOceanusForgeLayer {
        let table = layer.commission.schematics.oceanus
        let source = table.realizations
        guard source.count == table.declaredCount else {
            throw NatalSpineOceanusForgeFailure.sourceMismatch
        }

        let forged = source.enumerated().compactMap { index, realization in
            NatalSpineForgedOceanusRealization(
                sourceRow: index,
                realization: realization
            )
        }
        guard forged.count == source.count,
              forged.enumerated().allSatisfy({ index, value in
                  value.sourceRow == index && value.realization == source[index]
              }) else {
            throw NatalSpineOceanusForgeFailure.sourceMismatch
        }

        return NatalSpineOceanusForgeLayer(
            commission: layer.commission,
            substrate: layer.substrate,
            themis: layer.themis,
            oceanus: forged
        )
    }
}
