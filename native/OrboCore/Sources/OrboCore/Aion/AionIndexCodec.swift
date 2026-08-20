import Foundation

private struct AionIndexDocument: Decodable {
    let schemaVersion: Int
    let notation: String
    let ownership: String
    let supportedStartJD: Double
    let supportedEndJD: Double
    let families: [String: [AionSegmentDocument]]

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case notation
        case ownership
        case supportedStartJD = "supported_start_jd_ut"
        case supportedEndJD = "supported_end_jd_ut"
        case families
    }
}

private struct AionSegmentDocument: Decodable {
    let shellSignID: String
    let shellID: String
    let shellOrdinal: Int
    let signOrdinal: Int
    let startJD: Double
    let endJD: Double
    let crossings: [AionCrossingDocument]

    enum CodingKeys: String, CodingKey {
        case shellSignID = "shell_sign_id"
        case shellID = "shell_id"
        case shellOrdinal = "shell_ordinal"
        case signOrdinal = "sign_ordinal"
        case startJD = "start_jd_ut"
        case endJD = "end_jd_ut"
        case crossings
    }
}

private struct AionCrossingDocument: Decodable {
    let julianDay: Double
    let motion: AionCrossingMotion

    enum CodingKeys: String, CodingKey {
        case julianDay = "jd_ut"
        case motion
    }
}

public extension AionIndex {
    /// Decode the compact runtime artifact manufactured from the canonical Pass 5 tables.
    static func decode(_ data: Data) throws -> AionIndex {
        let document: AionIndexDocument
        do {
            document = try JSONDecoder().decode(AionIndexDocument.self, from: data)
        } catch {
            throw AionError.malformedIndex("runtime index JSON decode failed: \(error)")
        }

        guard document.schemaVersion == Self.schemaVersion else {
            throw AionError.malformedIndex(
                "unsupported Aion schema \(document.schemaVersion); expected \(Self.schemaVersion)"
            )
        }
        guard document.notation == "Shell.sign" else {
            throw AionError.malformedIndex("unexpected notation \(document.notation)")
        }
        guard document.ownership == "[first_direct_ingress, next_sign_first_direct_ingress)" else {
            throw AionError.malformedIndex("unexpected ownership law")
        }
        guard let supportedStart = JulianDay(document.supportedStartJD),
              let supportedEnd = JulianDay(document.supportedEndJD) else {
            throw AionError.malformedIndex("invalid supported Julian Day range")
        }

        var rowsByFamily: [AionFamily: [AionSegment]] = [:]
        for family in AionFamily.addressOrder {
            guard let documents = document.families[family.rawValue] else {
                throw AionError.missingFamily(family)
            }

            var rows: [AionSegment] = []
            rows.reserveCapacity(documents.count)
            for row in documents {
                guard let sign = Sign(rawValue: row.signOrdinal - 1),
                      let start = JulianDay(row.startJD),
                      let end = JulianDay(row.endJD) else {
                    throw AionError.malformedIndex("invalid row \(row.shellSignID)")
                }

                var crossings: [AionCrossing] = []
                crossings.reserveCapacity(row.crossings.count)
                for crossing in row.crossings {
                    guard let jd = JulianDay(crossing.julianDay) else {
                        throw AionError.malformedIndex(
                            "invalid crossing in \(row.shellSignID)"
                        )
                    }
                    crossings.append(AionCrossing(julianDay: jd, motion: crossing.motion))
                }

                guard let segment = AionSegment(
                    family: family,
                    shellID: row.shellID,
                    shellOrdinal: row.shellOrdinal,
                    shellSignID: row.shellSignID,
                    sign: sign,
                    signOrdinal: row.signOrdinal,
                    start: start,
                    end: end,
                    crossings: crossings
                ) else {
                    throw AionError.malformedIndex("failed invariant check: \(row.shellSignID)")
                }
                rows.append(segment)
            }
            rowsByFamily[family] = rows.sorted { $0.start.value < $1.start.value }
        }

        return try AionIndex(
            supportedStart: supportedStart,
            supportedEnd: supportedEnd,
            rowsByFamily: rowsByFamily
        )
    }
}
