import Foundation

public enum CivilTime {
    /// Phase 1b v1 operating range, aligned to the current Orbo temporal instrument.
    /// Spine v1 may later narrow this by intersection, but Civil Time must not silently widen it.
    public static let supportedYearRange = 1700...2149

    /// Version of the timezone rules bundled with the running operating system.
    public static var timeZoneDataVersion: String {
        NSTimeZone.timeZoneDataVersion
    }

    public static func resolve(
        date: CivilDate,
        time: CivilClockTime,
        in timezoneIdentifier: TimezoneIdentifier
    ) -> CivilTimeResolution {
        guard supportedYearRange.contains(date.year) else {
            return .unsupportedYear(date.year)
        }
        guard date.calendar == .gregorian else {
            return .unsupportedCalendar(date.calendar)
        }
        guard let timeZone = TimeZone(identifier: timezoneIdentifier.rawValue) else {
            return .unknownTimeZone(timezoneIdentifier)
        }

        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        var anchorComponents = DateComponents()
        anchorComponents.year = date.year
        anchorComponents.month = date.month
        anchorComponents.day = date.day
        anchorComponents.hour = 0
        anchorComponents.minute = 0
        anchorComponents.second = 0

        guard let nominalDay = utcCalendar.date(from: anchorComponents) else {
            return .nonexistent
        }

        // Start well before the requested local day. A strict full-component search cannot
        // drift into another date/year; it either finds this wall-clock reading or returns nil.
        let anchor = nominalDay.addingTimeInterval(-48 * 3_600)

        var localCalendar = Calendar(identifier: .gregorian)
        localCalendar.timeZone = timeZone
        var components = DateComponents()
        components.year = date.year
        components.month = date.month
        components.day = date.day
        components.hour = time.hour
        components.minute = time.minute
        components.second = time.second

        let firstDate = localCalendar.nextDate(
            after: anchor,
            matching: components,
            matchingPolicy: .strict,
            repeatedTimePolicy: .first,
            direction: .forward
        )
        let lastDate = localCalendar.nextDate(
            after: anchor,
            matching: components,
            matchingPolicy: .strict,
            repeatedTimePolicy: .last,
            direction: .forward
        )

        guard let firstDate, let lastDate else {
            return .nonexistent
        }

        let first = match(
            for: firstDate,
            timezoneIdentifier: timezoneIdentifier,
            timeZone: timeZone
        )
        let last = match(
            for: lastDate,
            timezoneIdentifier: timezoneIdentifier,
            timeZone: timeZone
        )

        if abs(first.instant.unixSecondsSince1970 - last.instant.unixSecondsSince1970) >= 0.5 {
            let ordered = [first, last].sorted {
                $0.instant.unixSecondsSince1970 < $1.instant.unixSecondsSince1970
            }
            return .ambiguous(first: ordered[0], second: ordered[1])
        }

        return .resolved(first)
    }

    public static func resolve(
        date: CivilDate,
        time: CivilClockTime,
        fixedOffset: UTCOffset
    ) -> CivilTimeResolution {
        resolve(date: date, time: time, offset: fixedOffset, source: .fixedOffset)
    }

    public static func resolveLocalMeanTime(
        date: CivilDate,
        time: CivilClockTime,
        longitude: GeographicLongitude
    ) -> CivilTimeResolution {
        resolve(
            date: date,
            time: time,
            offset: UTCOffset.localMeanTime(for: longitude),
            source: .localMeanTime
        )
    }

    public static func julianDay(
        date: CivilDate,
        time: CivilClockTime,
        offset: UTCOffset
    ) -> JulianDay {
        // Calendar-aware AAF law made canonical: Gregorian uses the century correction,
        // Julian does not. The offset is the already-applied east-positive civil offset.
        let utHours = Double(time.hour)
            + Double(time.minute) / 60
            + Double(time.second) / 3_600
            - offset.hoursEast

        var year = date.year
        var month = date.month
        let day = Double(date.day) + utHours / 24
        if month <= 2 {
            year -= 1
            month += 12
        }

        let correction: Int
        switch date.calendar {
        case .gregorian:
            let century = Int(floor(Double(year) / 100))
            correction = 2 - century + Int(floor(Double(century) / 4))
        case .julian:
            correction = 0
        }

        let value = floor(365.25 * Double(year + 4_716))
            + floor(30.6001 * Double(month + 1))
            + day
            + Double(correction)
            - 1_524.5

        return JulianDay(value)!
    }

    private static func resolve(
        date: CivilDate,
        time: CivilClockTime,
        offset: UTCOffset,
        source: CivilTimeSource
    ) -> CivilTimeResolution {
        guard supportedYearRange.contains(date.year) else {
            return .unsupportedYear(date.year)
        }

        let jd = julianDay(date: date, time: time, offset: offset)
        let instant = AbsoluteInstant(julianDay: jd)!
        return .resolved(
            CivilTimeMatch(
                instant: instant,
                offset: offset,
                timezone: nil,
                source: source,
                isDaylightSavingTime: nil,
                abbreviation: nil
            )
        )
    }

    private static func match(
        for date: Date,
        timezoneIdentifier: TimezoneIdentifier,
        timeZone: TimeZone
    ) -> CivilTimeMatch {
        let instant = AbsoluteInstant(unixSecondsSince1970: date.timeIntervalSince1970)!
        let offset = UTCOffset(secondsEast: timeZone.secondsFromGMT(for: date))!

        return CivilTimeMatch(
            instant: instant,
            offset: offset,
            timezone: timezoneIdentifier,
            source: .timeZoneDatabase,
            isDaylightSavingTime: timeZone.isDaylightSavingTime(for: date),
            abbreviation: timeZone.abbreviation(for: date)
        )
    }
}
