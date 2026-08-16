import Foundation

public enum CivilCalendar: String, Codable, Hashable, Sendable {
    case gregorian
    case julian
}

public struct CivilDate: Hashable, Codable, Sendable {
    public let year: Int
    public let month: Int
    public let day: Int
    public let calendar: CivilCalendar

    public init?(
        year: Int,
        month: Int,
        day: Int,
        calendar: CivilCalendar = .gregorian
    ) {
        guard year >= 1, year <= 9999, month >= 1, month <= 12 else { return nil }
        guard day >= 1, day <= Self.daysInMonth(year: year, month: month, calendar: calendar) else { return nil }
        self.year = year
        self.month = month
        self.day = day
        self.calendar = calendar
    }

    private static func daysInMonth(year: Int, month: Int, calendar: CivilCalendar) -> Int {
        switch month {
        case 4, 6, 9, 11:
            return 30
        case 2:
            return isLeapYear(year, calendar: calendar) ? 29 : 28
        default:
            return 31
        }
    }

    private static func isLeapYear(_ year: Int, calendar: CivilCalendar) -> Bool {
        switch calendar {
        case .gregorian:
            return year.isMultiple(of: 4) && (!year.isMultiple(of: 100) || year.isMultiple(of: 400))
        case .julian:
            return year.isMultiple(of: 4)
        }
    }
}

public struct CivilClockTime: Hashable, Codable, Sendable {
    public let hour: Int
    public let minute: Int
    public let second: Int

    public init?(hour: Int, minute: Int, second: Int = 0) {
        guard (0...23).contains(hour), (0...59).contains(minute), (0...59).contains(second) else { return nil }
        self.hour = hour
        self.minute = minute
        self.second = second
    }
}

public struct UTCOffset: Hashable, Codable, Sendable {
    public let secondsEast: Int

    /// Civil offset from UTC, positive east of Greenwich.
    public init?(secondsEast: Int) {
        guard (-86_400...86_400).contains(secondsEast) else { return nil }
        self.secondsEast = secondsEast
    }

    public init?(hoursEast: Double) {
        guard hoursEast.isFinite else { return nil }
        self.init(secondsEast: Int((hoursEast * 3_600).rounded()))
    }

    public static func localMeanTime(for longitude: GeographicLongitude) -> UTCOffset {
        // 360 degrees / 24 hours = 15 degrees per hour = 240 seconds per degree.
        UTCOffset(secondsEast: Int((longitude.degrees * 240).rounded()))!
    }

    public var hoursEast: Double {
        Double(secondsEast) / 3_600
    }

    public var clockDescription: String {
        let sign = secondsEast < 0 ? "-" : "+"
        let absolute = abs(secondsEast)
        let hours = absolute / 3_600
        let minutes = (absolute % 3_600) / 60
        let seconds = absolute % 60

        if seconds == 0 {
            return String(format: "%@%02d:%02d", sign, hours, minutes)
        }
        return String(format: "%@%02d:%02d:%02d", sign, hours, minutes, seconds)
    }
}

public struct JulianDay: Hashable, Codable, Sendable {
    public static let unixEpoch = JulianDay(2_440_587.5)!

    public let value: Double

    public init?(_ value: Double) {
        guard value.isFinite else { return nil }
        self.value = value
    }
}

public struct AbsoluteInstant: Hashable, Codable, Sendable {
    public let unixSecondsSince1970: Double

    public init?(unixSecondsSince1970: Double) {
        guard unixSecondsSince1970.isFinite else { return nil }
        self.unixSecondsSince1970 = unixSecondsSince1970
    }

    public init?(julianDay: JulianDay) {
        self.init(
            unixSecondsSince1970: (julianDay.value - JulianDay.unixEpoch.value) * 86_400
        )
    }

    public var julianDay: JulianDay {
        JulianDay(unixSecondsSince1970 / 86_400 + JulianDay.unixEpoch.value)!
    }

    internal var foundationDate: Date {
        Date(timeIntervalSince1970: unixSecondsSince1970)
    }
}

public enum CivilTimeSource: String, Codable, Hashable, Sendable {
    case timeZoneDatabase
    case fixedOffset
    case localMeanTime
}

public struct CivilTimeMatch: Hashable, Sendable {
    public let instant: AbsoluteInstant
    public let offset: UTCOffset
    public let timezone: TimezoneIdentifier?
    public let source: CivilTimeSource
    public let isDaylightSavingTime: Bool?
    public let abbreviation: String?

    internal init(
        instant: AbsoluteInstant,
        offset: UTCOffset,
        timezone: TimezoneIdentifier?,
        source: CivilTimeSource,
        isDaylightSavingTime: Bool?,
        abbreviation: String?
    ) {
        self.instant = instant
        self.offset = offset
        self.timezone = timezone
        self.source = source
        self.isDaylightSavingTime = isDaylightSavingTime
        self.abbreviation = abbreviation
    }
}

public enum CivilTimeResolution: Equatable, Sendable {
    case resolved(CivilTimeMatch)
    case ambiguous(first: CivilTimeMatch, second: CivilTimeMatch)
    case nonexistent
    case unknownTimeZone(TimezoneIdentifier)
    case unsupportedYear(Int)
    case unsupportedCalendar(CivilCalendar)
}
