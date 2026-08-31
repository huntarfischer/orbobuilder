import Foundation

public struct NatalSpineBounds: Hashable, Sendable {
    public let subjectID: HermesSubjectID
    public let start: AbsoluteInstant
    public let natal: AbsoluteInstant
    public let end: AbsoluteInstant

    public init?(
        subjectID: HermesSubjectID,
        start: AbsoluteInstant,
        natal: AbsoluteInstant,
        end: AbsoluteInstant
    ) {
        guard start.unixSecondsSince1970 < natal.unixSecondsSince1970,
              natal.unixSecondsSince1970 < end.unixSecondsSince1970 else {
            return nil
        }
        self.subjectID = subjectID
        self.start = start
        self.natal = natal
        self.end = end
    }

    public var bone: OrboSpineBoneSpan {
        OrboSpineBoneSpan(
            start: start.julianDay,
            end: end.julianDay
        )!
    }

    public func contains(_ instant: AbsoluteInstant) -> Bool {
        instant.unixSecondsSince1970 >= start.unixSecondsSince1970
            && instant.unixSecondsSince1970 < end.unixSecondsSince1970
    }
}

public enum NatalSpineClothoFailure: Error, Hashable, Sendable {
    case invalidLifeDomain
}

public extension Clotho {
    /// Gives the Natal Spine one finite UT-bound life domain without copying
    /// any Mundane OrboSpine matter or performing astrological calculation.
    static func boundNatalSpine(
        _ truth: NatalSpineNativeTruth
    ) throws -> NatalSpineBounds {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let natalDate = truth.tempus.absoluteInstant.foundationDate
        guard let startDate = calendar.date(byAdding: .year, value: -1, to: natalDate),
              let endDate = calendar.date(byAdding: .year, value: 100, to: natalDate),
              let start = AbsoluteInstant(
                unixSecondsSince1970: startDate.timeIntervalSince1970
              ),
              let end = AbsoluteInstant(
                unixSecondsSince1970: endDate.timeIntervalSince1970
              ),
              let bounds = NatalSpineBounds(
                subjectID: truth.subjectID,
                start: start,
                natal: truth.tempus.absoluteInstant,
                end: end
              ) else {
            throw NatalSpineClothoFailure.invalidLifeDomain
        }

        return bounds
    }
}
