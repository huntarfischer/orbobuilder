import Foundation

public enum NatalSpineExportRange: Hashable, Sendable {
    case entireSpine
    case nextYears(Int, anchor: JulianDay)
    case custom(ChronosInterval)
}

public enum NatalSpineExportRangeFailure: Error, Hashable, Sendable {
    case invalidYearCount
    case anchorOutsideSpine
    case rangeOutsideSpine
}

public struct NatalSpineMountedChronosIndex: Sendable {
    public let subjectID: HermesSubjectID
    public let packageID: HermesPackageID
    public let bounds: NatalSpineBounds
    fileprivate let spine: NatalSpineRuntime

    fileprivate init(spine: NatalSpineRuntime) {
        subjectID = spine.subjectID
        packageID = spine.packageID
        bounds = spine.bounds
        self.spine = spine
    }
}

public extension Chronos {
    static func indexNatalSpine(
        _ spine: NatalSpineRuntime
    ) -> NatalSpineMountedChronosIndex {
        NatalSpineMountedChronosIndex(spine: spine)
    }

    /// Resolves mounted Natal Spine facts without consulting the forge,
    /// Ephemeris, or the parent Mundane Spine.
    static func resolveNatalSpine(
        _ query: ChronosQuery,
        using index: NatalSpineMountedChronosIndex
    ) throws -> ChronosResolution {
        let spine = index.spine
        let hits: [ChronosHit]
        switch query.predicate {
        case let .natalHousePassage(body, house):
            hits = spine.themis.compactMap { record in
                guard record.body == body, record.house == house,
                      let interval = ChronosInterval(start: record.start, endExclusive: record.end) else {
                    return nil
                }
                return ChronosHit(
                    address: .interval(interval),
                    fact: .natalHousePassage(body: body, house: house),
                    source: natalSource(spine, layer: "themis", row: record.sourceRow)
                )
            }

        case let .natalRingRealization(body, gene, relation):
            hits = spine.oceanus.compactMap { record in
                guard body == nil || body == record.mundaneBody,
                      gene == nil || gene == record.natalGene,
                      relation == nil || relation == record.relation else { return nil }
                return ringHit(
                    record,
                    spine: spine,
                    fact: .natalRingRealization(
                        mundaneBody: body,
                        natalGene: gene,
                        relation: relation
                    )
                )
            }

        case let .natalHouseCrossing(body, fromHouse, toHouse):
            hits = spine.rhea.compactMap { record in
                guard case let .houseCrossing(eventBody, from, to, _, _, occurrence) = record.source,
                      body == nil || body == eventBody,
                      fromHouse == nil || fromHouse == from,
                      toHouse == nil || toHouse == to else { return nil }
                return crossingHit(
                    record,
                    body: eventBody,
                    from: from,
                    to: to,
                    occurrence: occurrence,
                    spine: spine,
                    fact: .natalHouseCrossing(
                        body: body,
                        fromHouse: fromHouse,
                        toHouse: toHouse
                    )
                )
            }

        case let .natalMaterCondition(condition, body):
            hits = spine.rhea.compactMap { record in
                guard record.conditions.contains(condition),
                      body == nil || body == record.source.body else { return nil }
                return ChronosHit(
                    address: .moment(record.source.occurrence),
                    fact: .natalMaterCondition(condition: condition, body: body),
                    source: natalSource(spine, layer: "rhea", row: record.sourceRow),
                    eventContext: context(for: record, spine: spine)
                )
            }

        default:
            throw NatalSpineChronosFailure.unsupportedPredicate
        }
        return .resolved(apply(query, to: ChronosAnswer(hits: hits)))
    }

    /// Combines only exact Ring realizations and exact native-house crossings.
    /// Long house-occupancy spans remain queryable but do not flood calendars.
    static func natalSpineExportAnswer(
        using index: NatalSpineMountedChronosIndex,
        range: NatalSpineExportRange
    ) throws -> ChronosAnswer {
        let interval = try resolvedNatalRange(range, within: index.bounds)
        let spine = index.spine
        let ring = spine.oceanus.compactMap { record -> ChronosHit? in
            intervalContains(interval, record.occurrence.julianDay)
                ? ringHit(record, spine: spine) : nil
        }
        let crossings = spine.rhea.compactMap { record -> ChronosHit? in
            guard case let .houseCrossing(body, from, to, _, _, occurrence) = record.source,
                  intervalContains(interval, occurrence) else { return nil }
            return crossingHit(
                record,
                body: body,
                from: from,
                to: to,
                occurrence: occurrence,
                spine: spine
            )
        }
        return ChronosAnswer(hits: ring + crossings)
    }

    static func resolvedNatalRange(
        _ range: NatalSpineExportRange,
        within bounds: NatalSpineBounds
    ) throws -> ChronosInterval {
        switch range {
        case .entireSpine:
            return ChronosInterval(start: bounds.bone.start, endExclusive: bounds.bone.end)!

        case let .nextYears(years, anchor):
            guard years > 0 else { throw NatalSpineExportRangeFailure.invalidYearCount }
            guard bounds.bone.contains(anchor) else {
                throw NatalSpineExportRangeFailure.anchorOutsideSpine
            }
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(secondsFromGMT: 0)!
            let startInstant = AbsoluteInstant(julianDay: anchor)!
            guard let proposed = calendar.date(
                byAdding: .year,
                value: years,
                to: startInstant.foundationDate
            ), let proposedInstant = AbsoluteInstant(
                unixSecondsSince1970: proposed.timeIntervalSince1970
            ) else {
                throw NatalSpineExportRangeFailure.invalidYearCount
            }
            let end = JulianDay(min(proposedInstant.julianDay.value, bounds.bone.end.value))!
            guard let interval = ChronosInterval(start: anchor, endExclusive: end) else {
                throw NatalSpineExportRangeFailure.rangeOutsideSpine
            }
            return interval

        case let .custom(requested):
            let start = JulianDay(max(requested.start.value, bounds.bone.start.value))!
            let end = JulianDay(min(requested.endExclusive.value, bounds.bone.end.value))!
            guard let interval = ChronosInterval(start: start, endExclusive: end) else {
                throw NatalSpineExportRangeFailure.rangeOutsideSpine
            }
            return interval
        }
    }
}

private extension Chronos {
    static func intervalContains(_ interval: ChronosInterval, _ day: JulianDay) -> Bool {
        day.value >= interval.start.value && day.value < interval.endExclusive.value
    }

    static func natalSource(
        _ spine: NatalSpineRuntime,
        layer: String,
        row: Int
    ) -> ChronosSourceReference {
        ChronosSourceReference(
            rawValue: "natal-spine:\(spine.artifactSHA256):\(layer):\(row)"
        )!
    }

    static func ringHit(
        _ record: NatalSpineRuntimeOceanusRecord,
        spine: NatalSpineRuntime,
        fact: ChronosFactIdentity? = nil
    ) -> ChronosHit {
        ChronosHit(
            address: .moment(record.occurrence.julianDay),
            fact: fact ?? .natalRingRealization(
                mundaneBody: record.mundaneBody,
                natalGene: record.natalGene,
                relation: record.relation
            ),
            source: natalSource(spine, layer: "oceanus", row: record.sourceRow),
            eventContext: context(for: record, spine: spine)
        )
    }

    static func crossingHit(
        _ record: NatalSpineRuntimeRheaRecord,
        body: MundaneBody,
        from: House,
        to: House,
        occurrence: JulianDay,
        spine: NatalSpineRuntime,
        fact: ChronosFactIdentity? = nil
    ) -> ChronosHit {
        ChronosHit(
            address: .moment(occurrence),
            fact: fact ?? .natalHouseCrossing(body: body, fromHouse: from, toHouse: to),
            source: natalSource(spine, layer: "rhea", row: record.sourceRow),
            eventContext: context(for: record, spine: spine)
        )
    }

    static func context(
        for record: NatalSpineRuntimeOceanusRecord,
        spine: NatalSpineRuntime
    ) -> ChronosEventContext {
        let linkedMater = spine.rhea.first { rhea in
            if case let .ringRealization(_, sourceRow, _) = rhea.source {
                return sourceRow == record.sourceRow
            }
            return false
        }
        return ChronosEventContext(
            stableUID: "natal-\(spine.artifactSHA256)-oceanus-\(record.sourceRow)@orbo",
            ring: [
                "Transit: \(record.mundaneBody.displayName) \(coordinateText(record.occurrence.directionalDegree))",
                "Natal target: \(record.natalGene.displayName) \(ringStateText(record.natalSource))",
                "Relationship: \(String(describing: record.relation))",
                "Exact occurrence: JD \(record.occurrence.julianDay.value)",
            ],
            tympan: tympanLines(
                body: record.mundaneBody,
                at: record.occurrence.julianDay,
                spine: spine
            ),
            mater: linkedMater.map(materLines) ?? [],
            orbo: orboLines(spine)
        )!
    }

    static func context(
        for record: NatalSpineRuntimeRheaRecord,
        spine: NatalSpineRuntime
    ) -> ChronosEventContext {
        ChronosEventContext(
            stableUID: "natal-\(spine.artifactSHA256)-rhea-\(record.sourceRow)@orbo",
            tympan: tympanLines(
                body: record.source.body,
                at: record.source.occurrence,
                spine: spine
            ),
            mater: materLines(record),
            orbo: orboLines(spine)
        )!
    }

    static func tympanLines(
        body: MundaneBody,
        at day: JulianDay,
        spine: NatalSpineRuntime
    ) -> [String] {
        let spans = spine.themis.filter { $0.body == body }.sorted { $0.start.value < $1.start.value }
        guard let index = spans.firstIndex(where: {
            day.value >= $0.start.value - 1e-9 && day.value < $0.end.value - 1e-9
        }) else { return [] }
        let current = spans[index]
        var result = ["Current native house: \(current.house.rawValue)"]
        if index > 0 { result.append("Previous native house: \(spans[index - 1].house.rawValue)") }
        if index + 1 < spans.count { result.append("Following native house: \(spans[index + 1].house.rawValue)") }
        result.append("House entry: JD \(current.start.value)")
        result.append("House exit: JD \(current.end.value)")
        return result
    }

    static func materLines(_ record: NatalSpineRuntimeRheaRecord) -> [String] {
        guard !record.conditions.isEmpty else { return [] }
        return [
            "Transit longitude: \(String(format: "%.6f", record.longitude.degrees)) degrees",
            "Recorded conditions: \(record.conditions.map(conditionText).joined(separator: ", "))",
        ]
    }

    static func orboLines(_ spine: NatalSpineRuntime) -> [String] {
        [
            "Natal Spine: \(spine.artifactSHA256)",
            "Parent Mundane Spine: \(spine.parentProvenance.spineIdentity)",
            "Subject: \(spine.subjectID.rawValue)",
        ]
    }

    static func coordinateText(_ degree: OrboSpineDirectionalDegree) -> String {
        "\(String(format: "%.6f", degree.physicalDegrees)) degrees \(degree.motion == .retrograde ? "retrograde" : "direct")"
    }

    static func ringStateText(_ state: RingFineState) -> String {
        let degrees = Double(state.arcsecond) / Double(Ring.arcsecondsPerDegree)
        return "\(String(format: "%.6f", degrees)) degrees \(state.motion == .retrograde ? "retrograde" : "direct")"
    }

    static func conditionText(_ condition: NatalSpineMaterCondition) -> String {
        switch condition {
        case .sectDay: return "day sect"
        case .sectNight: return "night sect"
        case .traditionalDomicile: return "traditional domicile"
        case .modernDomicile: return "modern domicile"
        case .traditionalDetriment: return "traditional detriment"
        case .modernDetriment: return "modern detriment"
        case .exaltation: return "exaltation"
        case .atExaltationDegree: return "exact exaltation degree"
        case .triplicity: return "triplicity"
        case .bound: return "bound"
        case .face: return "face"
        case .fall: return "fall"
        case .peregrine: return "peregrine"
        case .mutualReception: return "mutual reception"
        }
    }
}
