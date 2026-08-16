public struct Latitude: Hashable, Codable, Sendable {
    public let degrees: Double

    /// Geographic latitude in signed decimal degrees. Valid values are [-90, 90].
    public init?(_ degrees: Double) {
        guard degrees.isFinite, degrees >= -90, degrees <= 90 else { return nil }
        self.degrees = degrees == 0 ? 0 : degrees
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(Double.self)
        guard let value = Self(raw) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Latitude requires a finite value in [-90, 90]."
            )
        }
        self = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(degrees)
    }
}

public struct GeographicLongitude: Hashable, Codable, Sendable {
    public let degrees: Double

    /// Geographic longitude in signed decimal degrees. Valid values are [-180, 180].
    /// Unlike celestial longitude, this value is not cyclically normalized.
    public init?(_ degrees: Double) {
        guard degrees.isFinite, degrees >= -180, degrees <= 180 else { return nil }
        self.degrees = degrees == 0 ? 0 : degrees
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(Double.self)
        guard let value = Self(raw) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "GeographicLongitude requires a finite value in [-180, 180]."
            )
        }
        self = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(degrees)
    }
}

public struct TimezoneIdentifier: Hashable, Codable, Sendable, RawRepresentable {
    public let rawValue: String

    /// A stable timezone-jurisdiction identifier such as `America/Chicago`.
    /// Civil offset and daylight-saving resolution belong to the Civil Time subsystem.
    public init?(rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        self.rawValue = trimmed
    }

    public init?(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }
}

public struct Place: Hashable, Codable, Sendable {
    public let canonicalName: String
    public let latitude: Latitude
    public let longitude: GeographicLongitude
    public let timezone: TimezoneIdentifier

    public init?(
        canonicalName: String,
        latitude: Latitude,
        longitude: GeographicLongitude,
        timezone: TimezoneIdentifier
    ) {
        let trimmed = canonicalName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        self.canonicalName = trimmed
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
    }
}
