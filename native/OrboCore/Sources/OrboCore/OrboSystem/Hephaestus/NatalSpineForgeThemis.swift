public struct NatalSpineForgedThemisSpan: Hashable, Sendable {
    public let sourceRow: Int
    public let span: NatalSpineHouseSpan

    public init?(sourceRow: Int, span: NatalSpineHouseSpan) {
        guard sourceRow >= 0 else { return nil }
        self.sourceRow = sourceRow
        self.span = span
    }
}

public struct NatalSpineThemisForgeLayer: Hashable, Sendable {
    public let commission: NatalSpineForgeCommission
    public let substrate: NatalSpineCelestialSubstrate
    public let themis: [NatalSpineForgedThemisSpan]

    fileprivate init(
        commission: NatalSpineForgeCommission,
        substrate: NatalSpineCelestialSubstrate,
        themis: [NatalSpineForgedThemisSpan]
    ) {
        self.commission = commission
        self.substrate = substrate
        self.themis = themis
    }

    public var subjectID: HermesSubjectID { commission.subjectID }
    public var bounds: NatalSpineBounds { commission.schematics.bounds }
}

public enum NatalSpineThemisForgeFailure: Error, Hashable, Sendable {
    case substrateMismatch
    case sourceMismatch
}

public extension Hephaestus {
    static func forgeNatalSpineThemis(
        for commission: NatalSpineForgeCommission,
        on substrate: NatalSpineCelestialSubstrate
    ) throws -> NatalSpineThemisForgeLayer {
        guard substrate.subjectID == commission.subjectID,
              substrate.bounds == commission.schematics.bounds else {
            throw NatalSpineThemisForgeFailure.substrateMismatch
        }

        let source = commission.schematics.themis.spans
        let forged = source.enumerated().compactMap { index, span in
            NatalSpineForgedThemisSpan(sourceRow: index, span: span)
        }
        guard forged.count == source.count,
              forged.enumerated().allSatisfy({ index, value in
                  value.sourceRow == index && value.span == source[index]
              }) else {
            throw NatalSpineThemisForgeFailure.sourceMismatch
        }

        return NatalSpineThemisForgeLayer(
            commission: commission,
            substrate: substrate,
            themis: forged
        )
    }
}
