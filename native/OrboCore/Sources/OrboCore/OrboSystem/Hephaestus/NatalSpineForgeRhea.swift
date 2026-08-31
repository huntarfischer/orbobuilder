public enum NatalSpineForgedRheaFactReference: Hashable, Sendable {
    case themisCrossing(previousSourceRow: Int, nextSourceRow: Int)
    case oceanusRealization(sourceRow: Int)
}

public struct NatalSpineForgedRheaQualification: Hashable, Sendable {
    public let sourceRow: Int
    public let fact: NatalSpineForgedRheaFactReference
    public let qualification: NatalSpineMaterQualification

    public init?(
        sourceRow: Int,
        fact: NatalSpineForgedRheaFactReference,
        qualification: NatalSpineMaterQualification
    ) {
        guard sourceRow >= 0 else { return nil }
        self.sourceRow = sourceRow
        self.fact = fact
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
    case orphanQualification
}

public extension Hephaestus {
    /// ACT II Beat 5. Attaches every Atropos-certified Mater qualification to
    /// the temporal fact already forged into the child body. No Mater law,
    /// Ring geometry, house derivation, or celestial timing is recomputed here.
    static func forgeNatalSpineRhea(
        on layer: NatalSpineOceanusForgeLayer
    ) throws -> NatalSpineRheaForgeLayer {
        let table = layer.commission.schematics.rhea
        let source = table.qualifications
        guard source.count == table.declaredCount else {
            throw NatalSpineRheaForgeFailure.sourceMismatch
        }

        var forged: [NatalSpineForgedRheaQualification] = []
        forged.reserveCapacity(source.count)

        for (sourceRow, qualification) in source.enumerated() {
            let fact: NatalSpineForgedRheaFactReference
            switch qualification.source {
            case let .houseCrossing(crossing):
                guard let reference = themisCrossingReference(
                    crossing,
                    in: layer.themis
                ) else {
                    throw NatalSpineRheaForgeFailure.orphanQualification
                }
                fact = reference

            case let .ringRealization(realization):
                guard let row = layer.oceanus.first(where: {
                    $0.realization == realization
                }) else {
                    throw NatalSpineRheaForgeFailure.orphanQualification
                }
                fact = .oceanusRealization(sourceRow: row.sourceRow)
            }

            guard let value = NatalSpineForgedRheaQualification(
                sourceRow: sourceRow,
                fact: fact,
                qualification: qualification
            ) else {
                throw NatalSpineRheaForgeFailure.sourceMismatch
            }
            forged.append(value)
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

    private static func themisCrossingReference(
        _ crossing: NatalSpineHouseCrossing,
        in forged: [NatalSpineForgedThemisSpan]
    ) -> NatalSpineForgedRheaFactReference? {
        let spans = forged
            .filter { $0.span.body == crossing.body }
            .sorted { $0.span.start.value < $1.span.start.value }
        guard spans.count > 1 else { return nil }

        for index in 1..<spans.count {
            let previous = spans[index - 1]
            let next = spans[index]
            guard previous.span.house == crossing.fromHouse,
                  next.span.house == crossing.toHouse,
                  abs(previous.span.end.value - crossing.occurrence.value) <= 1e-9,
                  abs(next.span.start.value - crossing.occurrence.value) <= 1e-9 else {
                continue
            }
            return .themisCrossing(
                previousSourceRow: previous.sourceRow,
                nextSourceRow: next.sourceRow
            )
        }
        return nil
    }
}
