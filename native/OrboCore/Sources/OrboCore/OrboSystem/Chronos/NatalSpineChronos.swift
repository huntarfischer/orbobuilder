public struct NatalSpineChronosIndex: Sendable {
    public let subjectID: HermesSubjectID
    public let packageID: HermesPackageID
    public let bounds: NatalSpineBounds

    fileprivate let spine: SealedNatalSpine
    fileprivate let themisSourceRows: [Int]
    fileprivate let oceanusSourceRows: [Int]
    fileprivate let rheaSourceRows: [Int]

    fileprivate init(spine: SealedNatalSpine) {
        self.subjectID = spine.subjectID
        self.packageID = spine.packageID
        self.bounds = spine.bounds
        self.spine = spine
        self.themisSourceRows = spine.candidate.themis.map(\.sourceRow)
        self.oceanusSourceRows = spine.candidate.oceanus.map(\.sourceRow)
        self.rheaSourceRows = spine.candidate.rhea.map(\.sourceRow)
    }
}

public enum NatalSpineChronosFailure: Error, Hashable, Sendable {
    case unsupportedPredicate
}

public extension Chronos {
    /// ACT III Beat 3. Chronos indexes only immutable source-row addresses into
    /// the sealed Spine. The Spine remains the source of truth; the index owns
    /// no astrological calculation and no second chronology.
    static func indexNatalSpine(
        _ spine: SealedNatalSpine
    ) -> NatalSpineChronosIndex {
        NatalSpineChronosIndex(spine: spine)
    }

    /// Resolves one Natal Spine query using the existing Chronos query grammar.
    /// Source rows are dereferenced from the sealed Spine each time so indexed
    /// references cannot silently become replacement truth.
    static func resolveNatalSpine(
        _ query: ChronosQuery,
        using index: NatalSpineChronosIndex
    ) throws -> ChronosResolution {
        let base = try natalSpineAnswer(for: query.predicate, using: index)
        return .resolved(apply(query, to: base))
    }

    static func countNatalSpine(
        _ query: ChronosQuery,
        using index: NatalSpineChronosIndex
    ) throws -> Int {
        switch try resolveNatalSpine(query, using: index) {
        case let .resolved(answer): return answer.hits.count
        case .unresolved: return 0
        }
    }

    private static func natalSpineAnswer(
        for predicate: ChronosPredicate,
        using index: NatalSpineChronosIndex
    ) throws -> ChronosAnswer {
        let fact = factIdentity(for: predicate)

        switch predicate {
        case let .natalHousePassage(body, house):
            let hits = index.themisSourceRows.compactMap { sourceRow -> ChronosHit? in
                guard let forged = index.spine.candidate.themis.first(where: {
                    $0.sourceRow == sourceRow
                }), forged.span.body == body, forged.span.house == house,
                let interval = ChronosInterval(
                    start: forged.span.start,
                    endExclusive: forged.span.end
                ) else {
                    return nil
                }
                return ChronosHit(
                    address: .interval(interval),
                    fact: fact,
                    source: ChronosSourceReference(
                        rawValue: "natal-spine:themis:\(sourceRow)"
                    )
                )
            }
            return ChronosAnswer(hits: hits)

        case let .natalRingRealization(mundaneBody, natalGene, relation):
            let hits = index.oceanusSourceRows.compactMap { sourceRow -> ChronosHit? in
                guard let forged = index.spine.candidate.oceanus.first(where: {
                    $0.sourceRow == sourceRow
                }) else {
                    return nil
                }
                let realization = forged.realization
                if let mundaneBody, realization.mundaneBody != mundaneBody { return nil }
                if let natalGene, realization.natalGene != natalGene { return nil }
                if let relation, realization.relation != relation { return nil }
                return ChronosHit(
                    address: .moment(realization.occurrence.julianDay),
                    fact: fact,
                    source: ChronosSourceReference(
                        rawValue: "natal-spine:oceanus:\(sourceRow)"
                    )
                )
            }
            return ChronosAnswer(hits: hits)

        case let .natalHouseCrossing(body, fromHouse, toHouse):
            var hits: [ChronosHit] = []
            for candidateBody in MundaneBody.canonicalOrder {
                if let body, candidateBody != body { continue }
                let spans = index.spine.candidate.themis
                    .filter { $0.span.body == candidateBody }
                    .sorted { $0.span.start.value < $1.span.start.value }
                guard spans.count > 1 else { continue }

                for pairIndex in 1..<spans.count {
                    let previous = spans[pairIndex - 1]
                    let next = spans[pairIndex]
                    guard abs(previous.span.end.value - next.span.start.value) <= 1e-9,
                          previous.span.house != next.span.house else {
                        continue
                    }
                    if let fromHouse, previous.span.house != fromHouse { continue }
                    if let toHouse, next.span.house != toHouse { continue }
                    hits.append(
                        ChronosHit(
                            address: .moment(next.span.start),
                            fact: fact,
                            source: ChronosSourceReference(
                                rawValue: "natal-spine:themis:\(previous.sourceRow):\(next.sourceRow)"
                            )
                        )
                    )
                }
            }
            return ChronosAnswer(hits: hits)

        case let .natalMaterCondition(condition, body):
            let hits = index.rheaSourceRows.compactMap { sourceRow -> ChronosHit? in
                guard let forged = index.spine.candidate.rhea.first(where: {
                    $0.sourceRow == sourceRow
                }) else {
                    return nil
                }
                let qualification = forged.qualification
                if let body, qualification.source.body != body { return nil }
                guard condition.matches(qualification.temper) else { return nil }
                return ChronosHit(
                    address: .moment(qualification.source.julianDay),
                    fact: fact,
                    source: ChronosSourceReference(
                        rawValue: "natal-spine:rhea:\(sourceRow)"
                    )
                )
            }
            return ChronosAnswer(hits: hits)

        default:
            throw NatalSpineChronosFailure.unsupportedPredicate
        }
    }
}
