/// Orbo's temporal query authority.
///
/// Stage 1 proves only civic-time resolution. Chronos asks the existing
/// CivilTime authority for the absolute instant and returns temporal addresses;
/// he does not reproduce timezone law or civil-time arithmetic.
public enum Chronos {
    public static func resolveCivilMoment(
        date: CivilDate,
        time: CivilClockTime,
        in timezone: TimezoneIdentifier
    ) -> ChronosResolution {
        let fact = ChronosFactIdentity.civilMoment(
            date: date,
            time: time,
            timezone: timezone
        )
        let source = ChronosSourceReference(rawValue: "civil-time")!

        switch CivilTime.resolve(date: date, time: time, in: timezone) {
        case let .resolved(match):
            return .resolved(
                ChronosAnswer(
                    hits: [
                        ChronosHit(
                            address: .moment(match.instant.julianDay),
                            fact: fact,
                            source: source
                        )
                    ]
                )
            )

        case let .ambiguous(first, second):
            return .resolved(
                ChronosAnswer(
                    hits: [first, second].map { match in
                        ChronosHit(
                            address: .moment(match.instant.julianDay),
                            fact: fact,
                            source: source
                        )
                    }
                )
            )

        case .nonexistent:
            return .unresolved(.nonexistentCivilTime)

        case let .unknownTimeZone(identifier):
            return .unresolved(.unknownTimeZone(identifier))

        case let .unsupportedYear(year):
            return .unresolved(.unsupportedYear(year))

        case let .unsupportedCalendar(calendar):
            return .unresolved(.unsupportedCalendar(calendar))
        }
    }
}
