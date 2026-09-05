import Foundation

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

private struct NatalSpineThemisCrossingCandidate: Sendable {
    let previous: NatalSpineForgedThemisSpan
    let next: NatalSpineForgedThemisSpan
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

        let preparationStart = ProcessInfo.processInfo.systemUptime
        natalSpineForgeLog(
            "START source-preparation oceanus=\(layer.oceanus.count) themis=\(layer.themis.count)"
        )
        let oceanusByRealization = oceanusRealizationIndex(layer.oceanus)
        let themisByBoundary = themisCrossingIndex(layer.themis)
        natalSpineForgeLog(
            "END source-preparation elapsed=\(natalSpineElapsed(since: preparationStart))s oceanus-index=\(oceanusByRealization.count) themis-boundaries=\(themisByBoundary.count)"
        )

        let attachmentStart = ProcessInfo.processInfo.systemUptime
        natalSpineForgeLog("START structural-attachment qualifications=\(source.count)")
        var forged: [NatalSpineForgedRheaQualification] = []
        forged.reserveCapacity(source.count)

        for (sourceRow, qualification) in source.enumerated() {
            let fact: NatalSpineForgedRheaFactReference
            switch qualification.source {
            case let .houseCrossing(crossing):
                guard let reference = themisCrossingReference(
                    crossing,
                    in: themisByBoundary
                ) else {
                    natalSpineForgeLog(
                        "ORPHAN structural-attachment source-row=\(sourceRow) kind=themis-crossing"
                    )
                    throw NatalSpineRheaForgeFailure.orphanQualification
                }
                fact = reference

            case let .ringRealization(realization):
                guard let sourceRow = oceanusByRealization[realization] else {
                    natalSpineForgeLog(
                        "ORPHAN structural-attachment source-row=\(sourceRow) kind=oceanus-realization"
                    )
                    throw NatalSpineRheaForgeFailure.orphanQualification
                }
                fact = .oceanusRealization(sourceRow: sourceRow)
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

        natalSpineForgeLog(
            "END structural-attachment elapsed=\(natalSpineElapsed(since: attachmentStart))s input=\(source.count) output=\(forged.count) orphans=0"
        )
        return NatalSpineRheaForgeLayer(
            commission: layer.commission,
            substrate: layer.substrate,
            themis: layer.themis,
            oceanus: layer.oceanus,
            rhea: forged
        )
    }

    private static func oceanusRealizationIndex(
        _ forged: [NatalSpineForgedOceanusRealization]
    ) -> [NatalSpineRingRealization: Int] {
        var index: [NatalSpineRingRealization: Int] = [:]
        index.reserveCapacity(forged.count)
        for value in forged where index[value.realization] == nil {
            // A single temporal fact may carry multiple Mater qualifications.
            // Reusing its source row preserves that relationship without re-searching.
            index[value.realization] = value.sourceRow
        }
        return index
    }

    private static func themisCrossingIndex(
        _ forged: [NatalSpineForgedThemisSpan]
    ) -> [Int64: [NatalSpineThemisCrossingCandidate]] {
        let byBody = Dictionary(grouping: forged, by: { $0.span.body })
        var index: [Int64: [NatalSpineThemisCrossingCandidate]] = [:]

        for bodySpans in byBody.values {
            let ordered = bodySpans.sorted { $0.span.start.value < $1.span.start.value }
            guard ordered.count > 1 else { continue }

            for position in 1..<ordered.count {
                let previous = ordered[position - 1]
                let next = ordered[position]
                guard abs(previous.span.end.value - next.span.start.value) <= 1e-9 else {
                    continue
                }
                index[themisBoundaryKey(next.span.start.value), default: []].append(
                    NatalSpineThemisCrossingCandidate(previous: previous, next: next)
                )
            }
        }
        return index
    }

    private static func themisCrossingReference(
        _ crossing: NatalSpineHouseCrossing,
        in index: [Int64: [NatalSpineThemisCrossingCandidate]]
    ) -> NatalSpineForgedRheaFactReference? {
        let center = themisBoundaryKey(crossing.occurrence.value)
        for key in (center - 1)...(center + 1) {
            guard let candidates = index[key] else { continue }
            for candidate in candidates {
                let previous = candidate.previous
                let next = candidate.next
                guard previous.span.body == crossing.body,
                      next.span.body == crossing.body,
                      previous.span.house == crossing.fromHouse,
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
        }
        return nil
    }

    private static func themisBoundaryKey(_ value: Double) -> Int64 {
        Int64((value * 1_000_000_000).rounded())
    }

    private static func natalSpineElapsed(since start: TimeInterval) -> String {
        String(format: "%.3f", ProcessInfo.processInfo.systemUptime - start)
    }

    private static func natalSpineForgeLog(_ message: String) {
        FileHandle.standardOutput.write(Data("ORBO_NATAL_FORGE \(message)\n".utf8))
    }
}
